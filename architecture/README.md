# Architecture Documentation

## Overview
This document  describes the architecture for the Customer Feedback Platform, including AWS resources, data flow, and integration points.

## Diagram
See `architecture-diagram.png` (add your diagram here).

## Components
- API Gateway: Receives feedback submissions
- Lambda: Processes and analyzes feedback
- DynamoDB: Stores feedback and analysis
- ECS/EKS: Hosts analytics dashboard
- EventBridge/Lambda: Alerts and notifications
- CI/CD: Automated deployment pipeline
