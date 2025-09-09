from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from modules.resume.router import router as resume_router
from modules.employee.router import router as employee_router
from modules.department.router import router as department_router
from modules.jd.router import router as jd_router
from modules.okr.router import router as okr_router

app = FastAPI(
    title="AI HR 后端服务",
    description="AI HR 简历管理系统后端API",
    version="1.0.0"
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

@app.get("/")
async def root():
    return {"message": "AI HR 后端服务已启动"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)