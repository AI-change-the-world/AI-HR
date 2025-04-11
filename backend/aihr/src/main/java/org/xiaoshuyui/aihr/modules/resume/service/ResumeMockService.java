package org.xiaoshuyui.aihr.modules.resume.service;

import com.github.javafaker.Faker;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.xiaoshuyui.aihr.constant.ReservedPrompt;
import org.xiaoshuyui.aihr.modules.LLMService;
import org.xiaoshuyui.aihr.modules.resume.entity.ResumeCatalog;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@Service
public class ResumeMockService {

    static Faker faker = new Faker(new Locale("zh-CN"));

    @Resource
    LLMService llmService;

    public List<ResumeCatalog> mock() {
        List list = new ArrayList();
        for (int i = 0; i < 10; i++) {
            ResumeCatalog resumeCatalog = new ResumeCatalog();
            resumeCatalog.setName(faker.company().name());
            resumeCatalog.setId((long) i);
            list.add(resumeCatalog);
        }
        return list;
    }

    public String mockResume(String fake) {
        final String prompt = ReservedPrompt.FAKE_RESUME_PROMPT.replace("{{basic}}", fake);
        return llmService.chat(prompt);
    }
}
