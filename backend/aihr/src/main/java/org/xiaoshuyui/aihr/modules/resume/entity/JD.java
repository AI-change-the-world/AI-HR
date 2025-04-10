package org.xiaoshuyui.aihr.modules.resume.entity;

import lombok.Data;

import java.util.List;

@Data
public class JD {
    String jobTitle; // 职位名称
    List<JDRequirement> requirements; // 多个JD要求
}
