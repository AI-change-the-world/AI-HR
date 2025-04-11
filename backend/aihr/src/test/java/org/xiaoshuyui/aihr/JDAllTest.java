package org.xiaoshuyui.aihr;

import jakarta.annotation.Resource;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.xiaoshuyui.aihr.common.JsonObjectLoader;
import org.xiaoshuyui.aihr.constant.ReservedPrompt;
import org.xiaoshuyui.aihr.modules.LLMService;
import org.xiaoshuyui.aihr.modules.resume.entity.ScoreEvaluation;
import org.xiaoshuyui.aihr.modules.resume.entity.request.JDGenerateRequest;
import org.xiaoshuyui.aihr.modules.resume.service.ResumeMockService;

@SpringBootTest
public class JDAllTest {

    @Resource
    LLMService llmService;

    @Resource
    ResumeMockService resumeMockService;

    @Test
    public void test() {
        JDGenerateRequest jdGenerateRequest = new JDGenerateRequest();
        jdGenerateRequest.setJobName("Java开发工程师");
        jdGenerateRequest.setJobDescription("1. 熟悉Java语言，熟悉Java标准类库，熟悉Java集合框架，熟悉Java并发编程，熟悉Java反射机制，熟悉Java虚拟机，熟悉Java内存模型，熟悉Java序列化机制等");
        jdGenerateRequest.setMainPoint("熟悉Java语言，熟悉Java标准类库，熟悉Java集合框架，熟悉Java并发编程，熟悉Java反射机制，熟悉Java虚拟机，熟悉Java内存模型，熟悉Java序列化机制等");
        jdGenerateRequest.setExtraPoint("10年以上工作经验");
        jdGenerateRequest.setBonusPoint("业务能力强，无纹身，善言辞");

        final String prompt = ReservedPrompt.JD_GENERATE_PROMPT.replace("{{jobName}}", jdGenerateRequest.getJobName())
                .replace("{{jobDescription}}", jdGenerateRequest.getJobDescription())
                .replace("{{mainPoint}}", jdGenerateRequest.getMainPoint())
                .replace("{{extraPoint}}", jdGenerateRequest.getExtraPoint())
                .replace("{{bonusPoint}}", jdGenerateRequest.getBonusPoint());

        String generate = llmService.chat(prompt);
        System.out.println(generate);
        System.out.println("==================================");
        final String jdPoint = ReservedPrompt.JD_POINTS_PROMPT.replace("{{jd}}", generate);
        String chat = llmService.chat(jdPoint);
        System.out.println(chat);
        System.out.println("==================================");
        String jsonPrompt = ReservedPrompt.JD_TO_JSON_PROMPT.replace("{{jd}}", generate).replace("{{weights}}", chat);
        String chat1 = llmService.chat(jsonPrompt);
        System.out.println(chat1);
        System.out.println("==================================");
        final String fakeResume = resumeMockService.mockResume("张三，做过三年后端工程师，三年运维。精通c++");
        final String grade = ReservedPrompt.GRADE_RESUME_PROMPT.replace("{{grade}}", chat1).replace("{{resume}}", fakeResume);
        String chat2 = llmService.chat(grade);
        System.out.println(chat2);

        System.out.println("============  last step ==============");
        ScoreEvaluation scoreEvaluation = JsonObjectLoader.loadFromString(chat2, ScoreEvaluation.class, false);
        System.out.println(scoreEvaluation);
    }
}
