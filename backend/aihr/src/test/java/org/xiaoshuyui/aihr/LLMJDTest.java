package org.xiaoshuyui.aihr;

import jakarta.annotation.Resource;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.xiaoshuyui.aihr.common.JsonObjectLoader;
import org.xiaoshuyui.aihr.constant.ReservedPrompt;
import org.xiaoshuyui.aihr.modules.LLMService;
import org.xiaoshuyui.aihr.modules.resume.entity.JD;

@SpringBootTest
public class LLMJDTest {

    @Resource
    LLMService llmService;

    @Test
    public void test() {
        String prompt = ReservedPrompt.JD_TO_JSON_PROMPT.replace("{{jd}}", "- 本科及以上学历，计算机相关专业优先；\n" +
                "- 3年以上Java开发经验；\n" +
                "- 熟悉Spring框架，了解React更佳；\n" +
                "- 有团队协作能力，良好沟通能力；").replace("{{weights}}", "更关注工作经验，其次是技术能力，最后是学历和软技能。同时，仪表也很重要（需要外出见客户）");

        String chat = llmService.chat(prompt);
        System.out.println(chat);

        System.out.println("========================");
        JD jd = JsonObjectLoader.loadFromString(chat, JD.class, false);
        System.out.println(jd);
    }
}
