package org.xiaoshuyui.aihr;

import org.junit.jupiter.api.Test;
import org.xiaoshuyui.aihr.common.JsonObjectLoader;
import org.xiaoshuyui.aihr.modules.resume.entity.JD;

public class JsonLoaderTest {

    @Test
    public void jsonLoaderTest() {
        String json = """
                {
                  "jobTitle": "Java 开发工程师",
                  "requirements": [
                    {
                      "name": "工作经验",
                      "description": "3年以上Java开发经验",
                      "weight": 0.35
                    },
                    {
                      "name": "技术能力",
                      "description": "熟悉Spring框架，了解React更佳",
                      "weight": 0.25
                    },
                    {
                      "name": "学历要求",
                      "description": "本科及以上学历，计算机相关专业优先",
                      "weight": 0.15
                    },
                    {
                      "name": "软技能",
                      "description": "有团队协作能力，良好沟通能力",
                      "weight": 0.15
                    },
                    {
                      "name": "仪表形象",
                      "description": "形象良好，适合外出见客户",
                      "weight": 0.10
                    }
                  ]
                }
                """;

        JD jd = JsonObjectLoader.loadFromString(json, JD.class, false);
        System.out.println(jd);
    }
}
