import { assertFound } from "../utils/errors.js";
import { fileDatabase } from "./fileDatabase.js";

export async function listCatalog() {
  const db = await fileDatabase.read();
  return db.skills
    .filter((skill) => skill.status === "active")
    .map((skill) => ({
      ...skill,
      plans: db.skillPlans.filter((plan) => plan.skillId === skill.id && plan.status === "active")
    }));
}

export async function getSkillPlan(skillId: string, planId: string) {
  const db = await fileDatabase.read();
  const skill = assertFound(db.skills.find((item) => item.id === skillId && item.status === "active"), "skill_not_found", "Skill not found");
  const plan = assertFound(db.skillPlans.find((item) => item.id === planId && item.skillId === skillId && item.status === "active"), "plan_not_found", "Plan not found");
  return { skill, plan };
}
