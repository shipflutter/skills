#!/usr/bin/env python3
"""Upload AAB to Google Play Console."""
import sys, os, json, argparse
from google.oauth2 import service_account
import googleapiclient.discovery

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--aab", required=True)
    parser.add_argument("--service-account-json", required=True)
    parser.add_argument("--package-name", required=True)
    parser.add_argument("--track", default="internal")
    parser.add_argument("--release-status", default=None,
                        help="draft/completed/inProgress/halted (auto-detect if not set)")
    args = parser.parse_args()

    credentials = service_account.Credentials.from_service_account_file(
        args.service_account_json,
        scopes=["https://www.googleapis.com/auth/androidpublisher"]
    )
    service = googleapiclient.discovery.build(
        "androidpublisher", "v3", credentials=credentials
    )

    # Create edit
    edit = service.edits().insert(
        packageName=args.package_name, body={}
    ).execute()
    edit_id = edit["id"]
    print(f"  Created edit: {edit_id}")

    # Upload AAB
    with open(args.aab, "rb") as f:
        aab_response = service.edits().bundles().upload(
            packageName=args.package_name,
            editId=edit_id,
            media_body=args.aab,
            media_mime_type="application/octet-stream"
        ).execute()
    version_code = aab_response["versionCode"]
    print(f"  Uploaded AAB: version {version_code}")

    # Determine release status
    release_status = args.release_status
    if not release_status:
        # Try completed first, fall back to draft if app is new
        release_status = "completed"

    # Set track
    track_body = {
        "releases": [{
            "status": release_status,
            "versionCodes": [str(version_code)]
        }]
    }
    track_response = service.edits().tracks().update(
        packageName=args.package_name,
        editId=edit_id,
        track=args.track,
        body=track_body
    ).execute()
    print(f"  Track '{args.track}': {track_response['track']}")

    # Commit
    try:
        service.edits().commit(
            packageName=args.package_name, editId=edit_id
        ).execute()
        print(f"  ✓ Committed to {args.track} track ({release_status})")
    except Exception as e:
        if "draft" in str(e).lower():
            # Retry with draft status
            print(f"  ⚠ App is draft — retrying with draft status...")
            track_body["releases"][0]["status"] = "draft"
            service.edits().tracks().update(
                packageName=args.package_name,
                editId=edit_id,
                track=args.track,
                body=track_body
            ).execute()
            service.edits().commit(
                packageName=args.package_name, editId=edit_id
            ).execute()
            print(f"  ✓ Committed to {args.track} track (draft)")
        else:
            raise

if __name__ == "__main__":
    main()
