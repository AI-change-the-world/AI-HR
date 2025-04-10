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
}
