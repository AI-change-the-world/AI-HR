package org.xiaoshuyui.aihr.modules.resume.entity;

import lombok.Data;

import java.util.List;

@Data
public class ScoreEvaluation {
    List<Score> scores;
    double totalScore;
    String jobTitle;

    @Data
    public static class Score {
        String name;
        int score;
        double weight;
        double weightedScore;
        String description;
    }
}
