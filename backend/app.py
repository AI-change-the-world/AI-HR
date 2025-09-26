from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from modules.department.router import router as department_router
from modules.employee.router import router as employee_router
from modules.jd.router import router as jd_router
from modules.okr.router import router as okr_router
from modules.resume.router import router as resume_router
# 新增AI问答路由
from modules.ai_qa.router import router as ai_qa_router
# 新增任务管理路由
from modules.task.router import router as task_router
# 新增能力管理路由
from modules.capability.router import router as capability_router

app = FastAPI(
    title="AI HR 后端服务", description="AI HR 简历管理系统后端API", version="1.0.0"
)

# 添加CORS中间件，允许前端访问
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 包含各个模块的路由
app.include_router(resume_router)
app.include_router(employee_router)
app.include_router(department_router)
app.include_router(jd_router)
app.include_router(okr_router)
# 包含AI问答路由
app.include_router(ai_qa_router)
# 包含任务管理路由
app.include_router(task_router)
# 包含能力管理路由
app.include_router(capability_router)


@app.get("/")
async def root():
    return {"message": "AI HR 后端服务已启动"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
