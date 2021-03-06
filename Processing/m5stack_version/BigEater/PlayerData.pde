import java.io.*;
import java.util.*;

class PlayerData {
    private int score;
    private int health;
    private int bonus;
    private int combo;
    private HashMap<String, Integer> count = new HashMap<String, Integer>();
    private List<String> userChoice = new ArrayList<String>();
    private int cnt = 0;
    
    public PlayerData(String[] names) {
        score = 0;
        health = 3;
        combo = 0;
        bonus = 0;
        setCountMap(names);
    }
    
    public void getUserChoice(List<String> userChoice) {
        this.userChoice = userChoice;
    }
    
    public boolean isAlive() { return health > 0; }
    
    public void recordPlayerMove(Drop currentClass) {
        println(currentClass.getClassName());
        if (!(userChoice == null || userChoice.size() == 0)) {
            if (currentClass.getClassName().equalsIgnoreCase(userChoice.get(cnt))) {
                cnt++;
            }
        }
        else cnt = 0;
        
        modifyCount(currentClass.getClassName());
        modifyScoreAndHealth(currentClass.getClassName());
    }
    
    private void modifyCount(String name) {
        if ("virusA".equals(name) || "virusB".equals(name)) {
            int previousVal = count.get("virus");
            count.put("virus", previousVal + 1);
        }
        else {
            int previousVal = count.get(name);
            count.put(name, previousVal + 1);
        }
    }
    
    private void modifyScoreAndHealth(String name) {
        if (cnt == userChoice.size()) {
            cnt = 0;
            combo++; 
            score += 500;
        }
        else if (checkBadDropping(name)) health--;
        else {
            switch (name) {
                case "pineapple": 
                    score += 40;
                    break;
                case "crab":
                    score += 15;
                    break;
                case "eggplant":
                    score += 20;
                    break;
                case "salad":
                    score += 35;
                    break;
                case "fish":
                    score += 30;
                    break;
                case "cheese":
                    score += 10;
                    break;
                default: score += 0;    
            }
        }
    }
    
    private void setCountMap(String[] names) {
        for (String name : names) {
            if ("virusA".equals(name) || "virusB".equals(name)) 
                count.put("virus", 0);
            else
                count.put(name, 0);
        }
    }
    
    public int getScore() { return score; }
    
    public int getHealth() { return health; }
    
    public void loseHealth() { health--; }
    
    public void getBonus() { 
        bonus++;
        health += 2;
        score += 200;
    }
    
    private boolean checkBadDropping(String name) {
        return "virusA".equals(name) || "virusB".equals(name)||
                "bomb".equals(name);
    }
    
    public void saveUserData() {
        StringBuilder sb = new StringBuilder();
        sb.append("{\"datatype\":\"chart\",\"main\"::");
        sb.append("{\"score\":" + score + ",");
        sb.append("\"bonus\":" + bonus + ",");
        sb.append("\"combo\":" + combo + ",");
        int cnt = 0;
        for (String attribute : count.keySet()) {
            if ((cnt++) != 6) {
                sb.append("\"" + attribute + "\":" + count.get(attribute) + ",");
            }
            else {
                sb.append("\"" + attribute + "\":" + count.get(attribute) + "}");
            }
        }
        sb.append("}");
        
        client.publish("/BigEater", processMessageToBePublished(sb.toString()), 0, true);
    }
    
    
    
    private String processMessageToBePublished(String string) {
        StringBuilder sb = new StringBuilder("{");
        for (int i = 1; i < string.length() - 1; ++i) {
            if (string.charAt(i) == '\\') { continue; }
            if (string.charAt(i) == 'n' && string.charAt(i - 1) == '\\') { continue; }
            if (string.charAt(i + 1) == '{') { continue; }
            if (string.charAt(i - 1) == '}') { continue; }
            sb.append(String.valueOf(string.charAt(i)));
        }
        
        sb.append("}");
        return sb.toString();
    }
    
}
