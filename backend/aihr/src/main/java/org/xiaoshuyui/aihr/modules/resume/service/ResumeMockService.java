package org.xiaoshuyui.aihr.modules.resume.service;

import com.github.javafaker.Faker;
import org.springframework.stereotype.Service;
import org.xiaoshuyui.aihr.modules.resume.entity.ResumeCatalog;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@Service
public class ResumeMockService {

    static Faker faker = new Faker(new Locale("zh-CN"));

    public List<ResumeCatalog> mock(){
        List list = new ArrayList();
        for (int i=0;i<10;i++){
            ResumeCatalog resumeCatalog = new ResumeCatalog();
            resumeCatalog.setName(faker.company().name());
            resumeCatalog.setId((long) i);
            list.add(resumeCatalog);
        }
        return list;
    }
}
