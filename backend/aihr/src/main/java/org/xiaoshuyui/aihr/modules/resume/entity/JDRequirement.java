package org.xiaoshuyui.aihr.modules.resume.entity;

import lombok.Data;

@Data
public class JDRequirement {
    String name;      // 要求的名称（如学历要求、工作经验要求）
    String description; // 要求的描述（例如：“本科及以上，计算机相关专业优先”）
    double weight;    // 要求的权重（例如：学历要求权重为0.3）
}
