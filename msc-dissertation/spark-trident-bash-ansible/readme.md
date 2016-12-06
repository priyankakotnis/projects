<h2> Project Summary </h2>

This project contains the bash scripts and Ansible playbook that I wrote as part of my MSc dissertation.

The aim of the project was to capture and compare performance of Apache Spark Streaming and Apache Storm Trident jobs wordcount and grep. This was implemented on Google Compute Engine and University Cloud Machine. The performance metrics captured were CPU usage, Throughput and Latency.

Apache Kafka was used to feed input to Spark and Trident as in real-life systems. The data fed into Kafka was Twitter Tweet data downloaded using python script provided, which is a customised version of 'tweepy/examples/streaming.py'. The data was fed into Kafka using a Kafka's console producer script called through datafeed script.
