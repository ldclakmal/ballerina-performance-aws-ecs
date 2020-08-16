# Ballerina Performance Tests on Amazon ECS

Ballerina performance artifacts are used to continuously test the performance of Ballerina language versions.

These performance test scripts make use of Apache JMeter and a simple Netty Backend Service, which can echo back any 
requests.

Using Amazon Cloudformation, an ECS (Amazon Elastic Container Service) stack compromising of a Netty server, Ballerina 
service, and a JMeter client is created.
