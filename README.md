# SRE challenge

Hello!

Thank you for your interest shown by your application to join our team!

Among Namecheap teams, the Cloud team builds its own on-premise cloud-based architecture that is used for hosing WordPress websites, AI-generated websites, and CDN services along with other products. Such a large and loaded system needs constant monitoring and improvement, and this is exactly why we are looking for a newjoiners in the Site Raliability Engineering field. We expect that you will grow with us, learn a lot of new things and contribute to the stability and observability of our vast and complex infrastructure.

🌞 We have three tasks for you to demonstrate your thinking, analytic, debug and scripting skills. You have to clone this repository to complete the following challenges to your own GitHub account. 

Where to start: 

- Make a clone of this repository to your Github account
- Solve the tasks thoroughly
- Commit to your forked repository with your solutions into corresponding folders 

How to show your results: 

- Share the link to your forked repository with us

🍀 Good luck! 



## Task 1. A riddle from Sphynx about Nginx

Install any local K8s cluster (e.g. Minikube) on your machine and deploy Nginx webserver there. You are not limited in the ways to do it, though, it should be a cloud-native way. Logically, you will need to select some of Kubernetes resource types to use for your Nginx installation - we expect there to be several ones, so please provide us with YAML files of all the components that you chose. The success in this case is to access Nginx page in the browser.

So desired outcome: 
- YAML configuration files of all Kubernetes resources that you used 
- some explanations why you chose this or that component for your architectural vision
- any problems that you faced during the setup with short fix explanations
- if you wish to share any screenshots, commands used during investigation or logs you spotted - feel free to do it as well for sure! 

Please place the solution-related files to the `task1` folder in your forked repository.

## Task 2. PROMising SeQueL

We are showing a Prometheus alert example below, please check it along with the attached screenshot example and anwser the following questions:

```sh
  - alert: MysqlTransactionDeadlock
    expr: increase(mysql_global_status_innodb_row_lock_waits[2m]) > 0
    for: 3m
    labels:
      severity: warning
    annotations:
      dashboard: database-metrics
      summary: 'Mysql Transaction Waits'
    description: 'There are `{{ $value | humanize }}` MySQL connections waiting for a stale transaction to release.'
```

![Alt text](alert_example.png)

Based on this alert, please provide the answers to the following questions: 
- how could you potentially investigate the reasons of such alert appearance?
- would you recommend changing something in the alert for better convenience/readability/reaction?
- based on the alert example screenshot, would you change the alert options somehow to avoid potential alert fatigue? if yes, which way and why? if no, again why?
- can you suggest any other MySQL-related metric that can be used instead of the one we use in the example alert?

Please place the file with answers to these questions to the `task2` folder in your forked repository.

## Task 3. Well, we are in the SHell

Create a simple shell script to send a Slack notification based on specific Kubernetes event happening - if some pod fails due to incorrect image. 

Key points: 
- please include comments into your code that explain how this or that works
- feel free to use other languages if you have more experience there or think it will solve the task better
- no need to use real Slack channel if you do not want to, showing us the code would be totally enough. 
- if you wish to add some extra explanations about the script creation and work, you can create a separate file for them

Please place the script file (and explanations file if present) to the `task3` folder in your forked repository.