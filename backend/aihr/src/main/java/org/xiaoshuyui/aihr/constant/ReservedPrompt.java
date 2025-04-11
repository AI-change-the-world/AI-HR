package org.xiaoshuyui.aihr.constant;

public class ReservedPrompt {
    public static final String JD_TO_JSON_PROMPT = """
            请根据以下职位描述（JD）和关注重点，提取结构化信息，并生成一个包含要求项及其权重的 JSON。总权重为 1.0，各项可适当倾斜分配。
            
            JD：
            {{jd}}
            
            关注重点：
            {{weights}}
            
            输出格式要求：
            {
              "jobTitle": "岗位名称",
              "requirements": [
                {
                  "name": "学历要求",
                  "description": "本科及以上学历，计算机相关专业优先",
                  "weight": 0.2
                },
                {
                  "name": "工作经验",
                  "description": "3年以上Java开发经验",
                  "weight": 0.4
                },
                {
                  "name": "技能要求",
                  "description": "熟悉Spring、React等技术栈",
                  "weight": 0.3
                },
                {
                  "name": "软技能",
                  "description": "沟通能力和团队协作能力",
                  "weight": 0.1
                }
              ]
            }
            只输出 JSON 内容，不加任何解释。
            """;

    public static final String JD_GENERATE_PROMPT = """
            你是一名资深 HR 文案专家，请根据以下信息，撰写一份专业、清晰且吸引人的招聘启事（Job Description, JD）。JD 要包含岗位介绍、主要职责、任职要求（分为：必须项、额外项和加分项），语言简洁明了，适合直接发布在招聘网站上。
            
            【岗位名称】
            {{jobName}}
            
            【岗位职责】
            {{jobDescription}}
            
            【必须满足的主要要求】
            {{mainPoint}}
            
            【额外需求（非必须但优先考虑）】
            {{extraPoint}}
            
            【加分项（亮点优势）】
            {{bonusPoint}}
            
            请使用结构化格式输出，包含以下部分：
            1. 职位名称 \s
            2. 工作地点（如未提供可略） \s
            3. 岗位职责 \s
            4. 任职资格（分为“必须条件”、“优先条件”、“加分项”） \s
            5. 我们提供的福利（如未提供可写“面议”或略过） \s
            
            语言风格要：
            - 专业但不过于正式 \s
            - 清晰，便于快速浏览 \s
            - 每一条要求尽量用一句话表述，保持简洁 \s
            """;

    public static final String JD_POINTS_PROMPT = """
            你是一名资深 HR，请从以下招聘启事（JD）中提炼出最核心的 1 到 2 个要点。
            
            这些要点应能帮助 HR 快速判断这个岗位最重要看重的是什么，例如：技术能力、工作年限、稳定性、形象要求、沟通能力等。
            
            请输出简洁明了的一句话或两个 bullet 要点。
            
            【JD 内容】：
            {{jd}}
            """;

    public static final String FAKE_RESUME_PROMPT = """
            你是一位专业的职业简历撰写顾问，请根据以下基础信息，生成一份完整的中文个人简历。要求简历结构清晰、语言专业、可直接用于投递岗位。
            
              【基础信息】：
              {{basic}}

              【输出格式要求】：
              请按以下结构生成简历内容：

              1. 个人信息（如姓名、学历、联系方式可虚拟） \s
              2. 教育背景 \s
              3. 专业技能 \s
              4. 工作经历（如无可略） \s
              5. 项目经验（如无可略） \s
              6. 自我评价 \s

              语言风格要专业、真实、有一定亮点；每一部分内容不少于2～3句话，突出能力与优势。
            """;

    public static final String GRADE_RESUME_PROMPT= """
            你是一位专业的技术招聘官，请根据以下评分细则，对候选人的简历逐项评分。
            
            要求如下：
            
            1. 每条评分细则的满分为 100 分 \s
            2. 根据简历内容进行客观评估，给出每项评分（score），再乘以其对应权重（weight），得出加权得分（weightedScore） \s
            3. 最终输出结构化 JSON，包含：
                - 每项细则的名称、评分（score）、权重（weight）、加权得分（weightedScore）
                - 总分（totalScore），为所有 weightedScore 之和
            
            请直接返回 JSON 结构体，不要解释或附加说明。
            
            请使用如下格式返回评分结果（JSON），务必严格保持字段一致：
            
            {
              "jobTitle": "Java开发工程师",
              "scores": [
                {
                  "name": "...",
                  "description": "...",
                  "score": 0,
                  "weight": 0,
                  "weightedScore": 0
                },
                ...
              ],
              "totalScore": 0
            }
            
            【评分细则】：
            {{grade}}
            
            【候选人简历内容】：
            {{resume}}
            """;
}
