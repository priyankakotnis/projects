package com.example.project;

/**
 *
 * @author seahawk
 */
public class HelloWorldJava8 {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        TestInterface functionalInterface = (String name) -> {
            System.out.println("Hello Java 8 World !");
            System.out.println("Welcome " + name);
        };
        
        functionalInterface.sayHello("Priyanka");
    }

}
