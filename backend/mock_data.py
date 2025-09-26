#!/usr/bin/env python3
"""
Mock数据生成脚本
用于为AI-HR系统生成测试数据
"""

import json
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from config.database import SessionLocal, engine, Base
from models.task import Task, TaskDifficulty, TaskStatus, TaskPriority
from models.capability import Skill, EmployeeSkill, SkillLevel, SkillCategory
from models.employee import Employee
from models.department import Department


def create_mock_data():
    """创建mock数据"""
    # 创建数据库表
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    
    try:
        # 清理现有数据（可选）
        print("清理现有数据...")
        db.query(EmployeeSkill).delete()
        db.query(Task).delete()
        db.query(Skill).delete()
        db.commit()
        
        # 创建技能数据
        print("创建技能数据...")
        skills_data = [
            {
                "name": "React",
                "category": SkillCategory.TECHNICAL,
                "description": "React前端框架开发",
                "level_d_criteria": "了解React基础概念，能创建简单组件",
                "level_c_criteria": "能使用React开发基础功能，理解组件生命周期",
                "level_b_criteria": "熟练使用React开发复杂应用，掌握状态管理",
                "level_a_criteria": "精通React生态，能优化性能，指导团队开发",
                "level_s_criteria": "React专家，能设计架构，贡献开源项目"
            },
            {
                "name": "Python",
                "category": SkillCategory.TECHNICAL,
                "description": "Python编程语言",
                "level_d_criteria": "了解Python基础语法",
                "level_c_criteria": "能编写简单的Python脚本",
                "level_b_criteria": "熟练使用Python开发应用",
                "level_a_criteria": "精通Python，能设计复杂系统",
                "level_s_criteria": "Python专家，深度理解语言特性"
            },
            {
                "name": "项目管理",
                "category": SkillCategory.MANAGEMENT,
                "description": "项目规划和执行管理",
                "level_d_criteria": "了解项目管理基础概念",
                "level_c_criteria": "能参与项目管理活动",
                "level_b_criteria": "能独立管理小型项目",
                "level_a_criteria": "能管理复杂项目，协调多方资源",
                "level_s_criteria": "项目管理专家，能设计管理体系"
            },
            {
                "name": "UI设计",
                "category": SkillCategory.DESIGN,
                "description": "用户界面设计",
                "level_d_criteria": "了解UI设计基础原则",
                "level_c_criteria": "能设计简单的界面",
                "level_b_criteria": "能设计完整的产品界面",
                "level_a_criteria": "精通UI设计，能建立设计规范",
                "level_s_criteria": "设计专家，引领设计趋势"
            },
            {
                "name": "数据分析",
                "category": SkillCategory.BUSINESS,
                "description": "数据分析和洞察",
                "level_d_criteria": "了解数据分析基础概念",
                "level_c_criteria": "能进行简单的数据分析",
                "level_b_criteria": "熟练使用分析工具，产出有价值的洞察",
                "level_a_criteria": "精通数据分析，能设计分析框架",
                "level_s_criteria": "数据分析专家，能指导业务决策"
            },
            {
                "name": "英语",
                "category": SkillCategory.LANGUAGE,
                "description": "英语沟通能力",
                "level_d_criteria": "基础英语水平，能阅读简单文档",
                "level_c_criteria": "能进行基本的英语交流",
                "level_b_criteria": "流利的英语交流，能参与国际会议",
                "level_a_criteria": "精通英语，能进行商务谈判",
                "level_s_criteria": "母语级别，能进行专业写作"
            }
        ]
        
        skills = []
        for skill_data in skills_data:
            skill = Skill(**skill_data)
            db.add(skill)
            skills.append(skill)
        
        db.commit()
        
        # 刷新以获取ID
        for skill in skills:
            db.refresh(skill)
        
        print(f"创建了 {len(skills)} 个技能")
        
        # 获取现有员工（假设已有员工数据）
        employees = db.query(Employee).all()
        if not employees:
            print("警告：没有找到员工数据，请先创建员工")
            return
        
        # 为员工分配技能
        print("为员工分配技能...")
        employee_skills_data = [
            # 张三 - 技术人员
            {"employee_id": 1, "skill_name": "React", "level": SkillLevel.A},
            {"employee_id": 1, "skill_name": "Python", "level": SkillLevel.B},
            {"employee_id": 1, "skill_name": "英语", "level": SkillLevel.B},
            
            # 李四 - 设计师
            {"employee_id": 2, "skill_name": "UI设计", "level": SkillLevel.S},
            {"employee_id": 2, "skill_name": "React", "level": SkillLevel.C},
            {"employee_id": 2, "skill_name": "英语", "level": SkillLevel.A},
            
            # 王五 - 项目经理
            {"employee_id": 3, "skill_name": "项目管理", "level": SkillLevel.A},
            {"employee_id": 3, "skill_name": "数据分析", "level": SkillLevel.B},
            {"employee_id": 3, "skill_name": "英语", "level": SkillLevel.A},
        ]
        
        for emp_skill_data in employee_skills_data:
            # 查找员工和技能
            employee = db.query(Employee).filter(Employee.id == emp_skill_data["employee_id"]).first()
            skill = next((s for s in skills if s.name == emp_skill_data["skill_name"]), None)
            
            if employee and skill:
                emp_skill = EmployeeSkill(
                    employee_id=employee.id,
                    skill_id=skill.id,
                    level=emp_skill_data["level"],
                    assessment_date=datetime.now() - timedelta(days=30),
                    assessed_by=1,  # 假设ID为1的员工是评估者
                    assessment_notes=f"初始技能评估 - {emp_skill_data['level'].value}级"
                )
                db.add(emp_skill)
        
        db.commit()
        print(f"创建了 {len(employee_skills_data)} 个员工技能记录")
        
        # 创建任务数据
        print("创建任务数据...")
        tasks_data = [
            {
                "name": "开发用户登录功能",
                "description": "实现用户登录、注册和密码重置功能，包括前端界面和后端API",
                "difficulty": TaskDifficulty.MEDIUM,
                "status": TaskStatus.IN_PROGRESS,
                "priority": TaskPriority.HIGH,
                "assignee_id": 1,  # 张三
                "assigner_id": 3,  # 王五分配
                "assigned_at": datetime.now() - timedelta(days=5),
                "start_date": datetime.now() - timedelta(days=3),
                "due_date": datetime.now() + timedelta(days=10),
                "progress": 60,
                "estimated_hours": 40,
                "required_skills": json.dumps([
                    {"name": "React", "level": "B"},
                    {"name": "Python", "level": "B"}
                ]),
                "department_id": 1,  # 技术部
                "notes": "优先级较高，需要按时完成"
            },
            {
                "name": "设计系统UI组件库",
                "description": "创建可复用的UI组件库，包括按钮、表单、卡片等基础组件",
                "difficulty": TaskDifficulty.HARD,
                "status": TaskStatus.ASSIGNED,
                "priority": TaskPriority.MEDIUM,
                "assignee_id": 2,  # 李四
                "assigner_id": 3,  # 王五分配
                "assigned_at": datetime.now() - timedelta(days=2),
                "due_date": datetime.now() + timedelta(days=20),
                "progress": 0,
                "estimated_hours": 60,
                "required_skills": json.dumps([
                    {"name": "UI设计", "level": "A"}
                ]),
                "department_id": 2,  # 设计部
                "notes": "需要与开发团队密切配合"
            },
            {
                "name": "数据库性能优化",
                "description": "优化查询性能，添加索引，清理冗余数据，提升系统响应速度",
                "difficulty": TaskDifficulty.VERY_HARD,
                "status": TaskStatus.PENDING,
                "priority": TaskPriority.URGENT,
                "due_date": datetime.now() + timedelta(days=7),
                "progress": 0,
                "estimated_hours": 80,
                "required_skills": json.dumps([
                    {"name": "Python", "level": "A"},
                    {"name": "数据分析", "level": "B"}
                ]),
                "department_id": 1,  # 技术部
                "notes": "紧急任务，需要尽快安排合适人员"
            },
            {
                "name": "编写API文档",
                "description": "为所有API接口编写详细的文档，包括参数说明和示例",
                "difficulty": TaskDifficulty.EASY,
                "status": TaskStatus.COMPLETED,
                "priority": TaskPriority.LOW,
                "assignee_id": 1,  # 张三
                "assigner_id": 3,  # 王五分配
                "assigned_at": datetime.now() - timedelta(days=15),
                "start_date": datetime.now() - timedelta(days=12),
                "due_date": datetime.now() - timedelta(days=2),
                "completed_at": datetime.now() - timedelta(days=1),
                "progress": 100,
                "estimated_hours": 16,
                "actual_hours": 14,
                "quality_score": 9,
                "required_skills": json.dumps([
                    {"name": "Python", "level": "C"}
                ]),
                "department_id": 1,  # 技术部
                "notes": "已完成，质量良好"
            },
            {
                "name": "用户体验研究",
                "description": "进行用户访谈和可用性测试，收集用户反馈",
                "difficulty": TaskDifficulty.MEDIUM,
                "status": TaskStatus.ASSIGNED,
                "priority": TaskPriority.MEDIUM,
                "assignee_id": 2,  # 李四
                "assigner_id": 3,  # 王五分配
                "assigned_at": datetime.now() - timedelta(days=1),
                "due_date": datetime.now() + timedelta(days=14),
                "progress": 10,
                "estimated_hours": 32,
                "required_skills": json.dumps([
                    {"name": "UI设计", "level": "B"},
                    {"name": "数据分析", "level": "C"}
                ]),
                "department_id": 2,  # 设计部
                "notes": "需要与产品团队协调"
            }
        ]
        
        for task_data in tasks_data:
            task = Task(**task_data)
            db.add(task)
        
        db.commit()
        print(f"创建了 {len(tasks_data)} 个任务")
        
        print("Mock数据创建完成！")
        
    except Exception as e:
        print(f"创建mock数据时出错: {e}")
        db.rollback()
    finally:
        db.close()


if __name__ == "__main__":
    create_mock_data()