# Udacity A/B testing final project






At the time of this experiment, Udacity courses currently have two options on the course overview page: "start free trial", and "access course materials". 

- If the student clicks "start free trial", they will be asked to enter their credit card information, and then they will be enrolled in a free trial for the paid version of the course. After 14 days, they will automatically be charged unless they cancel first. 
- If the student clicks "access course materials", they will be able to view the videos and take the quizzes for free, but they will not receive coaching support or a verified certificate, and they will not submit their final project for feedback.



## Experiment Description

In the experiment, Udacity tested a change where if the student clicked "start free trial", they were asked how much time they had available to devote to the course. 

- If the student indicated 5 or more hours per week, they would be taken through the checkout process as usual. 
- If they indicated fewer than 5 hours per week, a message would appear indicating that Udacity courses usually require a greater time commitment for successful completion, and suggesting that the student might like to access the course materials for free. At this point, the student would have the option to continue enrolling in the free trial, or access the course materials for free instead. 

![Final Project_ Experiment Screenshot.png](https://i.loli.net/2020/07/12/eh9sTMD48Lbvrmt.png)







### Hypothesis

**Null Hypothesis :** This approach might not make a significant change and might not be effective in reducing the early Udacity course cancellation.

**Alternative Hypothesis :** It might reduce the number of frustrated students who left the free trial because they didn't have enough time, without significantly reducing the number of students to continue past the free trial and eventually complete the course.



## Experiment Setup

The unit of diversion is a **cookie**, although if the student enrolls in the free trial, they are tracked by user-id from that point forward. The same user-id cannot enroll in the free trial twice. For users that do not enroll, their user-id is not tracked in the experiment, even if they were signed in when they visited the course overview page.



### Metric Choice

- Invariant Metrics
  - **number of cookies**: number of unique cookies to **view** the course overview page. This is the unit of diversion and even distribution amongst the control and experiment groups is expected.
  - **Number of clicks**:  number of unique cookies to **click the "Start free trial" button** (which happens before the free trial screener is trigger). 

- Evaluation Metrics 
  - **Gross conversion:** number of user-ids to complete **checkout** and **enroll** in the free trial divided by number of unique cookies to click the "Start free trial" button. (dmin= 0.01)
  - **Net conversion:** number of user-ids to **remain enrolled** past the 14-day boundary (and thus make at least one payment) divided by the number of unique cookies to **click** the "Start free trial" button. (dmin= 0.0075)

We should decide whether to roll out the change by decreased gross conversion coupled to increase in net conversion, i.e, less students enrolling in free trial but more students staying beyound the free trial.



### Measuring Variability (Standard error)

For each of the metrics the standard deviation is calculated for a sample size of 5000 unique cookies visiting the course overview page. It is asked to calculate the variability of the metrics, i.e. standard deviation of them. It is probably the “standard deviation of the sampling distribution” or standard error(SE), rather than the simple SD. 

Baseline values to calculate SE

| Baseline                                         | Abbr     | Value  |
| ------------------------------------------------ | -------- | ------ |
| Unique cookies to view page / day                | $N_{C}$  | 40000  |
| Unique cookies to click “Start free trial” / day | $N_{CT}$ | 3200   |
| Enrollments / day                                | $N_{E}$  | 660    |
| Click-through-probability on “Start free trial”  | CTR      | 0.08   |
| Probability of enrolling, given click            | $P_{GC}$ | 0.2063 |
| Probability of payment, given enroll             | $P_{GC}$ | 0.53   |
| Probability of payment, given click              | $P_{NC}$ | 0.1093 |



1. Gross conversion 



$$ P_{GC}  = \displaystyle \frac {\text {# enrollments}} {\text {# clicks of 'Start free trial'}} =N_E/N_{CT}= 0.2063$$ 



When sample size N=5000, $N_{GC}=5000×CTR=400$.  Assuming it follows binomial distribution, its standard error is:

$$SE_{GC}=\sqrt{\frac{P_{GC}×(1-P_{GC})}{N_{GC}}}=0.0202$$



2. Net conversion

Similarly, 

$$P_{NC} = \displaystyle \frac{\text{# user-ids to remain enrolled}} { \text{#clicks of 'Start free trial'}}=0.1093$$  

$N_{NC}=5000 * CTR=400$



$SE_{NC}=\sqrt{\frac{P_{NC}×(1-P_{NC})}{N_{NC}}}=0.0156$



### Sizing

Based on the distribution of the metric, the sample size is a function of some parameters such as alpha, i.e. significance level, beta, false negative probability or type II error, baseline conversion, practical significance and so.

###  Gross Conversion

- Baseline conversion rate: 20.625%

- Minimum detectable effect: 1%

- alpha: 5%

- beta: 20%

  1 - beta: 80%

- sample size = 25,835 enrollments per group

- total sample size = 51,670 enrollments

- click through rate = .08 

- therefore, pageviews = 645,875



### Net Conversion

- Baseline conversion rate: 10.9313%

- Minimum detectable effect: .75%

- alpha: 5%

- beta: 20%

  1 - beta: 80%

- sample size = 27,413 enrollments per group

- total sample size = 54,826 enrollments

- click through rate = .08 

- therefore, pageviews = 685,325



Take the maximum of gross and net conversion, hence the required pageview is  685,325.



<img src="/images/AB-testing/post-abtesting2.jpg">

## Experiment Analysis

### Sanity Check

There are some metrics that are expected to have more or less identical values in the both experiment and control groups. I choose **the number of cookies**, **number of clicks**, and **click-through probability** as invariant metrics. 

Taking number of cookies (Pageviews) as an example:

|                                 | Pageviews | Clicks |
| ------------------------------- | --------- | ------ |
| N_control​                       | 345543    | 28378  |
| N_experiment                    | 344660    | 28325  |
| N_total                         | 690203    | 56703  |
| p                               | 0.5       | 0.5    |
| $\hat{p}$=  N_control / N_total | 0.5006    | 0.5005 |
| $SE= \sqrt{p×(1−p) /N_{total}}$ | 0.0006    | 0.0021 |
| margin=1.96×SE  (α=0.05)        | 0.0012    | 0.0041 |
| Lower bound=p−margin            | 0.4988    | 0.4959 |
| Upper bound=p+margin            | 0.5012    | 0.5041 |



Therefor, the result of sanity check is 

|             | Pageviews | Clicks | CTR       |
| ----------- | --------- | ------ | --------- |
| Lower-bound | 0.4988    | 0.4959 | -0.00013  |
| Upper-bound | 0.5012    | 0.5041 | +0.00013  |
| Observed    | 0.5006    | 0.5005 | +0.000057 |
| Passes      | Yes       | Yes    | Yes       |

###  Effect Size Tests



As all sanity checks were passed, and the experiment data is validated to some extent, we can go forward and analyze the evaluation metrics.

What we want to do is assessing whether the differences between evaluation metric values of the control and experiment groups are significant or not. Use 95% Confidence interval for the difference between the experiment and control group for evaluation metrics. The result is satistically significant only when the 95% confidence interval does not include zero. 



| Metric           | dmin   | Observed Difference | CI Lower Bound | CI Upper Bound | Result                                            |
| ---------------- | ------ | ------------------- | -------------- | -------------- | ------------------------------------------------- |
| Gross Conversion | 0.01   | -0.0205             | -.0291         | -.0120         | Satistically and Practically Significant          |
| Net Conversion   | 0.0075 | -0.0048             | -0.0116        | 0.0019         | Neither Statistically nor Practically Significant |

### Sign Test

Sign test is basically checking whether the signs, either positive or negative, of the differences of the metrics between two groups are meaningfully distributed over the days of the experiment or not. For instance, if in every single day of the experiment the gross conversion rate is lower in the experiment group comparing to the control group, then being so assures us further that this metric is significantly reduced due to the experiment.

The **null hypothesis** is the proportion of negative signs to the number of experiment days is a random and insignificant value. Thus, this is a one sample proportion test. For the net conversion rate sign test, I consider being negative as the baseline, and I check whether the observed number of negative values is statsitically significant or not.

Sign test is just an another method to validate the result obtained above. The sensitivity of sign test is lower than that of the above test.

| Metric           | p-value for sign test | Statistically Significant (alpha = .05)? |
| ---------------- | --------------------- | ---------------------------------------- |
| Gross Conversion | 0.0026                | Yes                                      |
| Net Conversion   | 0.6776                | No                                       |





## Summary

An experiment was conducted in which potential Udacity students were diverted by cookie into two groups, experiment and control. The experiment group was asked to input the amount of time they are willing to devote to study, after clicking a "start free trial button", whereas the control group was not. 

Three invariant metrics (Number of Cookies, Number of clicks on "start free trial", and Click-Through-Probability) were chosen for purposes of validation and sanity checking while Gross Conversion (enrollment/cookie) and Net Conversion (payments/cookie) served as evaluation metrics. 

The null hypothesis is that there is no difference in the evaluation metrics between the groups, futhermore, a practical signifcance threshold was set for each metric. 

Analysis showed the expected equal distribution of cookies into the control and experimental groups at the 95% CI. A difference in gross conversion was found to be statistically signficant at the 95% CI, and the null hypothesis was rejected. Gross conversion also met the practical signficance threshold. Net Conversion was found to be neither statistically nor practically signficant at the 95% CI.

## Recommendation

My recomendation is not to launch. We can design a follow-up experiment at this point. 

This experiment was designed to determine whether filtering students as a function of study time commitment would improve the overall student experience without significantly reducing the number of students who continue past the free trial. A statistically and practically signficant decrease in Gross Conversion was observed but with not in Net Conversion. This translates to a decrease in enrollment not coupled to an increase in students staying for 14 days boundary to trigger payment.

<img src="/images/AB-testing/post-abtesting3.png">
