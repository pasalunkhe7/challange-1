**# challange-1**

**Problem statement**

>A three-tier architecture is a kind of  micoservices structure which are divided  into three logical layers: the User interface layer, the business logic layer and the data storage layer.

**Approach**

>I have created this infrastructure by creating Web servers and loadbalanceing between them in public subnet and application server in private subnet.Also I have reated RDS mysql instace in db subnet. 
So This infra represt  3 layer environmnemt.
Below is the architecture for it and drawaing carried out in https://app.diagrams.net/

**Diagram**


![3-tire-infra drawio](https://user-images.githubusercontent.com/96169630/146349894-4e8a3984-a652-4572-bd83-922e6bdcf5a6.png)






**Infra created **

-VPC
-Internet gateway
-route table
-5 Subnets (2 public and 1 private and 2 db subnets in a 2 AZ's)
-Security groups
-EC-2 instances (2 for webserver and 1 for app server
-ELB (application load  Load balancer)
-Target group
-RDS instance
-Note:I have not created NAT instace due to time limitation to access private subnet which is also required.

**Instructions**:

>Configure CLI and also creat your profile and relace in the code for security reasons.
>and load all files and use below commands to launch infra.


-Run terraform init .
-Run terraform fmt               ...... This ensures your formatting is correct.
-terraform validate              ...........validate to ensure there are no syntax errors.
-Run terraform plan                  ............plan to see what resources will be created.
-Run terraform apply                  ............apply to creat a resurces
