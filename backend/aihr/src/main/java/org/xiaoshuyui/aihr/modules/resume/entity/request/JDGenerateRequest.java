package org.xiaoshuyui.aihr.modules.resume.entity.request;

import lombok.Data;

@Data
public class JDGenerateRequest {
    String jobName;
    String jobDescription;
    String mainPoint;
    String extraPoint;
    String bonusPoint;
}
