package com.example.project.task;

/**
 *
 * @author Priyanka Kotnis
 */
public class MyThreadRunner {
    
    public static void main(String[] args) {
        
        Runnable task1 = () -> {
            System.out.println("Task1 running...");
            System.out.println("Task1, this is something extra...");
        };
        Runnable task2 = () -> System.out.println("Task2 running...");
        
        new Thread(task2).start();
        new Thread(task1).start();
        
    }
    
}
