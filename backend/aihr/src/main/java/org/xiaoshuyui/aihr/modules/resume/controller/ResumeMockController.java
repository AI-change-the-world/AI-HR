package org.xiaoshuyui.aihr.modules.resume.controller;

import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;
import org.xiaoshuyui.aihr.common.Result;
import org.xiaoshuyui.aihr.common.SseUtil;
import org.xiaoshuyui.aihr.modules.resume.entity.request.GradeRequest;
import org.xiaoshuyui.aihr.modules.resume.service.ResumeMockService;

import java.util.concurrent.Executors;

import static java.lang.Thread.sleep;

@Slf4j
@RestController
@RequestMapping("/mock/resume")
@Data
public class ResumeMockController {
    final ResumeMockService resumeMockService;

    public ResumeMockController(ResumeMockService resumeMockService) {
        this.resumeMockService = resumeMockService;
    }

    @GetMapping("/catalog")
    public Result getCatalog() {
        return Result.OK_data(resumeMockService.mock());
    }

    @PostMapping("/grade")
    public SseEmitter grade(@RequestBody GradeRequest gradeRequest) {
        SseEmitter emitter = new SseEmitter( 1000L * 60 * 60);

        Executors.newSingleThreadExecutor().execute(() -> {
            SseUtil.sseSend(emitter, "初始化中...");
            sleepOneSecond();
            SseUtil.sseSend(emitter, "获取岗位信息...");
            sleepOneSecond();
            SseUtil.sseSend(emitter, "提取简历特征...");
            sleepOneSecond();
            SseUtil.sseSend(emitter, "匹配简历...");
            sleepOneSecond();
            SseUtil.sseSend(emitter, "简历评分中...");
            sleepOneSecond();
            SseUtil.sseSend(emitter, "得分详情请刷新页面");
            emitter.complete();
        });


        return emitter;
    }

    void sleepOneSecond(){
        try {
            sleep(1000);
        } catch (InterruptedException e) {
            log.error(e.getMessage());
        }
    }
}
