# Contributing to a Rearc AWS Data Exchange product

🎉🥳 First of all, **THANK YOU** for being interested in contributing to one of our projects 🎉🥳

### Table of Contents
- [What should I know before getting started?](#what-should-i-know-before-getting-started)
  * [What is AWS Data Exchange?](#what-is-aws-data-exchange)
  * [Who is Rearc?](#who-is-rearc)
  * [What are Rearc's goals for ADX?](#what-are-rearcs-goals-for-adx)
  * [What is Rearc's philosophy towards dataset formats?](#what-is-rearcs-philosophy-towards-dataset-formats)
  * [What tools are you using throughout your ADX Products?](#what-tools-are-you-using-throughout-your-adx-products)
- [How can I contribute?](#how-can-i-contribute)
  * [Report an Issue/Bug or Submit an Improvement/Suggestion](#report-an-issuebug-or-submit-an-improvementsuggestion)
  * [Pull Request](#pull-request)
- [Additional Resources](#additional-resources)

## What should I know before getting started?

#### What Is AWS Data Exchange?
> [AWS Data Exchange](https://aws.amazon.com/data-exchange/) is a data marketplace that makes it easy for AWS customers to securely find, subscribe to, and use third-party data in the cloud.

#### Who is Rearc?
[Rearc](https://www.rearc.io) is a data provider and one of the launch partners for AWS Data Exchange. Products published by Rearc on ADX can be found [here](https://aws.amazon.com/marketplace/seller-profile?id=a8a86da2-b2d1-4fae-992d-03494e90590b). On ADX we automate the (1) sourcing, (2) transformation, (3) creation, (4) revisions and, (5) publishing of datasets through ADX.

#### What are Rearc's goals for ADX?
We at Rearc are working tirelessly to lend greater accessibility to interesting and/or important datasets across various disciplines and sources. We realize the direct integration of the ADX, along with other AWS services, facilitates a convenient manner for our subscribers to consume data. For data providers we can supply an automation pipeline, leveraging the AWS platform, to ensure the ubiquity of your data for your consumers.

#### What is Rearc's philosophy towards dataset formats?
We try as much as possible to preserve the integrity of data we provide through ADX, and most of the time this means delivering datasets exactly as they were presented from their source. Sometimes we make minor alterations to datasets to provide wider usability for ADX subscribers (e.g. adjusting CSV files for SQL column naming conventions). For situations where we are unable to maintain the original data file format, we try to limit the extent of transformations as much as possible.

#### What tools are you using throughout your ADX Products?
- Our ADX products are primarily built with [Python 3](https://www.python.org), and use AWS [CloudFormation](https://docs.aws.amazon.com/cloudformation/) and [Lambda](https://docs.aws.amazon.com/lambda/) resources to offer automated revisions.
- As no two datasets are the same, the exact tools utilized vary on a project-by-project basis.

For more details on the technologies used in our ADX products, please visit [Getting started with publishing a data product on AWS Data Exchange](https://github.com/rearc-data/publish-a-data-product-on-aws-data-exchange).

## How can I contribute?

#### Report an Issue/Bug or Submit an Improvement/Suggestion
If you have feedback specific to the ADX product featured in this repository, the best way to contact us would be through [opening a GitHub issue]() in this repository. Before opening an issue please review the existing suggestions to see if your idea is already there. If already present, please comment on the existing issue instead of making a new one.

When opening an issue please **be as descriptive as possible**. If relevant please **provide information regarding your use-case, development configuration and environment**. The more specific you can be the easier it will be for us to identify and address the situation.

If you have a general inquiry about Rearc's data services you can send an email to data@rearc.io. We would love to hear any suggestion, question or request you may have. 

#### Pull Request
We actively encourage you to fork, branch and open a pull request on this repository! Before opening a pull request please familiarize yourself with the [tools](#what-tools-are-you-using-throughout-your-adx-products) used in our ADX Products. If you are looking to improve the project's included datasets you should direct yourself to the [`pre-processing/pre-processing-code`](./pre-processing/pre-processing-code) folder, as this is where the gathering and transforming of data occurs.

When you are ready to open a pull request, please **be as descriptive as possible** regarding all improvements you have made. After reviewing your pull request, we may ask you to complete additional changes before your pull request is accepted. If we are unable to accept your pull request, we will make sure to offer context for our decision.

## Additional Resources
- [Rearc Data Homepage](https://www.rearc.io/data)
- Rearc Data Email: data@rearc.io
- [Rearc AWS Marketplace Profile](https://aws.amazon.com/marketplace/seller-profile?id=a8a86da2-b2d1-4fae-992d-03494e90590b)