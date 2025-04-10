package org.xiaoshuyui.aihr.modules.resume.entity.response;

import lombok.Data;
import org.xiaoshuyui.aihr.modules.resume.entity.ResumeCatalog;

import java.util.List;

@Data
public class ResumeCatalogResponse {
    List<ResumeCatalog> catalogList;
}
