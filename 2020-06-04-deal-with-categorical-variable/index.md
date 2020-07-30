# Categorical variables encoding in machine learning -Part1




In this part one blog about categorical encoding, I will be introducing some common encoding methods that I have explored and pros and cons for each of them. 

## TL; DR

There is no 'one size fits all', and it usually depends on your data representations and requirements. If a variable has a lot of categories then a one-hot encoding scheme will produce many columns which can cause memory issues. In my experience relying on LightGBM/CatBoost is the best out-of-the-box method. Label encoding is a road to nowhere in most scenarios and you should be careful using it. However if your categorical variable happens to be ordinal then you can and should represent it with increasing numbers (for example “cold” becomes 0, “mild” becomes 1, and “hot” becomes 2). word2vec and others such methods are cool and good but they require some fine-tuning and don’t always work out. 

No matter what method do you choose, always consider how to deal with new categories in test data that not appear in train data.



## One-hot encoding

Assume we all have prior knowledge about creating dummy variables for categorical data. 

I am being judgemental and personally not a fan for OHE for two reasons:

1. One-hot encoding might not be the best way to preprocess the data, especially for **tree-based learners**.  For high-cardinality categorical features, a tree built on one-hot features tends to be unbalanced and needs to grow very deeeeep to achieve good accuracy.

2. There will be mismatch in train and test set. Specifically, after one-hot encoding the number of columns in the training and test set data can be unequal, and therefore, the model will throw error during predicting.



Workaround:

1. Get the missing columns and add them to the test dataset: (thanks to answer from [stackoverflow](https://stackoverflow.com/questions/41335718/keep-same-dummy-variable-in-training-and-testing-data)

```python
# Get missing columns in the training test
missing_cols = set( train.columns ) - set( test.columns )
# Add a missing column in test set with default value equal to 0
for c in missing_cols:
    test[c] = 0
# Ensure the order of column in the test set is in the same order than in train set
train, test = train.align(test, axis=1)
```

This code also ensure that column resulting from category in the test dataset but not present in the training dataset will be removed.



## Label  Encoding

One common way to deal with categories is to simply map each category with a number. By applying such transformation, a model would treat categories as ordered integers, which in some cases is wrong. Such transformation should not be used “as is” for several types of models (Linear Models, KNN, Neural Nets, etc.). 

```python
# Code for encoding multiple categorical columns
from sklearn.preprocessing import LabelEncoder
le=LabelEncoder()
# Iterating over all the common columns in train and test
for col in X_test.columns.values:
    # Encoding only categorical variables
    if X_test[col].dtypes=='object':
    # Using whole data to form an exhaustive list of levels
    data= X_train[col].append(X_test[col])
    le.fit(data.values)
    X_train[col]=le.transform(X_train[col])
    X_test[col]=le.transform(X_test[col])
```





## Optimal Binning in tree-learners

LightGBM or CatBoost have built-in [Optimal binning](https://github.com/Microsoft/LightGBM/blob/master/docs/Advanced-Topics.rst#categorical-feature-support) which is very convinent and well-performed. In fact in my experience relying on LightGBM/CatBoost is the best out-of-the-box method. While applying gradient boosting it could be used only if the type of a column is specified as [*“category”*](https://pandas.pydata.org/pandas-docs/stable/user_guide/categorical.html). New categories in Label Encoder are replaced with “-1” or None. If you are working with gradient boosting model  (especially Lightgbm) , LE is the simplest way to work with categories in terms of memory (the **category type in python consumes much less memory than the object type**).

```python
category_col = data.select_dtypes('object').columns.tolist()
for c in category_col:
        X_train[c] = X_train[c].astype('category')
        X_test[c] = X_test[c].astype('category')
        
d_train = lgb.Dataset(X_train, label=y_train,
                      free_raw_data=False,
                      feature_name=X.columns.tolist(),
                      categorical_feature=cat_col) # specify categorical columns while forming train and valid data matrix
```
Upon further reflection, for LightGBM, it looks like simply using the [built-in categorical encoding](https://github.com/Microsoft/LightGBM/blob/master/docs/Features.rst#optimal-split-for-categorical-features) is outperforming any kind of categorical encoding I can personally do.





## Target Encoder (TE)

I have encoutered many TE on kaggle winners solutions so I decided to try it out. It takes information about the target to encode categories, which makes it extremely powerful. The encoded category values are calculated according to the following formulas:

![](https://miro.medium.com/max/772/1*CQ0CSJY8yBq0P0L4i2ztwQ.png)





Target encoding is a fast way to get the most out of your categorical variables with little effort. The idea is quite simple. Say we can have a categorical variable $X$ and a target $Y$. For each distinct element in $X$  we're going to compute the average of the corresponding values in $Y$ (It doesn't matter whether Y is continuous or binary). Then we're going to replace each $X_i$ with the according mean. This is rather easy to do in Python and the `pandas` library.

First let’s create some dummy data.

```python
import pandas as pd
df = pd.DataFrame({
    'x_0': ['a'] * 3 + ['b'] * 3,
    'x_1': ['c'] * 1 + ['d'] * 5,
    'y': [1, 0, 1, 0, 1, 0]})
```

Here's how data looks like.

|      | x_0  | x_1  | y    |
| ---- | ---- | ---- | ---- |
| 0    | a    | c    | 1    |
| 1    | a    | d    | 1    |
| 2    | a    | d    | 1    |
| 3    | b    | d    | 0    |
| 4    | b    | d    | 1    |
| 5    | b    | d    | 0    |

Replace each value in x_0 with the matching mean.

```python
df['x_0'] = df['x_0'].map(df.groupby('x_0')['y'].mean())
df['x_1'] = df['x_1'].map(df.groupby('x_1')['y'].mean())
```

We now have the following data frame.

|      | x_0      | x_1  | y    |
| ---- | -------- | ---- | ---- |
| 0    | 0.666667 | 1.0  | 1    |
| 1    | 0.666667 | 0.4  | 0    |
| 2    | 0.666667 | 0.4  | 1    |
| 3    | 0.333333 | 0.4  | 0    |
| 4    | 0.333333 | 0.4  | 1    |
| 5    | 0.333333 | 0.4  | 0    |

Target encoding is good because it picks up values that can explain the target. 

In this vanilla example value a of variable x_0 has an average target value of 0.67. This can greatly help the machine learning classifications algorithms used downstream.

The problem of target encoding is **target leakage**. It uses information about the target. Because of the target leakage, model **overfits** the training data. 

In the example, the value d of variable x_1 is replaced with a 1 because it only appears once and the corresponding value of y is a 1. In this case we’re over-fitting because we don’t have enough values to be *sure* that 1 is in fact the mean value of y when x_1 is equal to d. In other words only relying on each group mean is too reckless.

A popular way to reduce target leakage is to use cross-validation and compute the means in each out-of-fold dataset. This is [what H20 does](http://docs.h2o.ai/h2o/latest-stable/h2o-docs/data-munging/target-encoding.html) and what many Kagglers do too. Another approach is to use [additive smoothing](https://www.wikiwand.com/en/Additive_smoothing). This is supposedly [what IMDB uses to rate it’s movies](https://www.wikiwand.com/en/Bayes_estimator#/Practical_example_of_Bayes_estimators).



##  James-Stein Encoder

James-Stein Encoder is a target-based encoder. The idea behind James-Stein Encoder is simple. Encoding is aimed to improve the estimation of the category’s mean target (first member of the amount) by shrinking them towards a more central average (second member of the amount). See more in the [document](http://contrib.scikit-learn.org/category_encoders/jamesstein.html). 



## Helmert Encoder

Helmert coding compares each level of a categorical variable to the mean of the subsequent levels. Hence, the first contrast compares the mean of the dependent variable for “A” with the mean of all of the subsequent levels of categorical column (“B”, “C”, “D”), the second contrast compares the mean of the dependent variable for “B” with the mean of all of the subsequent levels (“C”, “D”), and the third contrast compares the mean of the dependent variable for “C” with the mean of all of the subsequent levels (in our case only one level — “D”).

This type of encoding can be useful in certain situations where levels of the categorical variable are ordered, say, from lowest to highest, or from smallest to largest.



---



Reference

https://www.kaggle.com/c/avito-demand-prediction/discussion/55521

https://www.kaggle.com/ogrellier/python-target-encoding-for-categorical-features

https://stackoverflow.com/questions/21057621/sklearn-labelencoder-with-never-seen-before-values





