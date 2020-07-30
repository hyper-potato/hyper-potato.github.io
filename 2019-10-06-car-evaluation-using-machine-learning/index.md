# Beginner's guide for predictive models




In this post, I will apply decision tree, k-NN, SVM to predict the evaluation of the cars based on their characteristics. Dataset is from [UCI ML Repository](https://archive.ics.uci.edu/ml/datasets/Car+Evaluation).

More specifically, I will explore how well these techniques perform for several different parameter values.

Present a brief overview of the predictive modeling process, explorations, and discuss my results. Then I will present the final model and discuss its performance in a comprehensive manner (overall accuracy; per-class performance, i.e., whether this model predicts all classes equally well, or if there some classes for which it does much better than others; etc.)

Let's hit the road. 

## Data Exploration


```python
#Importing the basic libraries
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
plt.style.use('ggplot')
import plotly.offline as py
import seaborn as sns

%matplotlib inline
#%config InlineBackend.figure_format = 'svg'

from warnings import simplefilter
# ignore all future warnings
simplefilter(action='ignore', category=FutureWarning)
```


```python
cars = pd.read_csv('car.data', names =  ['buying', 'maint', 'doors','capacity','lug_boot','safety','class'])
```


```python
#Taking an overview of data
cars.sample(10)
```


<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
    
    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>buying</th>
      <th>maint</th>
      <th>doors</th>
      <th>capacity</th>
      <th>lug_boot</th>
      <th>safety</th>
      <th>class</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>975</th>
      <td>med</td>
      <td>high</td>
      <td>2</td>
      <td>2</td>
      <td>med</td>
      <td>low</td>
      <td>unacc</td>
    </tr>
    <tr>
      <th>277</th>
      <td>vhigh</td>
      <td>med</td>
      <td>4</td>
      <td>2</td>
      <td>big</td>
      <td>med</td>
      <td>unacc</td>
    </tr>
    <tr>
      <th>1219</th>
      <td>med</td>
      <td>low</td>
      <td>3</td>
      <td>2</td>
      <td>med</td>
      <td>med</td>
      <td>unacc</td>
    </tr>
    <tr>
      <th>1316</th>
      <td>low</td>
      <td>vhigh</td>
      <td>2</td>
      <td>more</td>
      <td>small</td>
      <td>high</td>
      <td>unacc</td>
    </tr>
    <tr>
      <th>249</th>
      <td>vhigh</td>
      <td>med</td>
      <td>3</td>
      <td>2</td>
      <td>big</td>
      <td>low</td>
      <td>unacc</td>
    </tr>
    <tr>
      <th>1712</th>
      <td>low</td>
      <td>low</td>
      <td>5more</td>
      <td>4</td>
      <td>small</td>
      <td>high</td>
      <td>good</td>
    </tr>
    <tr>
      <th>1676</th>
      <td>low</td>
      <td>low</td>
      <td>4</td>
      <td>2</td>
      <td>small</td>
      <td>high</td>
      <td>unacc</td>
    </tr>
    <tr>
      <th>1374</th>
      <td>low</td>
      <td>vhigh</td>
      <td>4</td>
      <td>more</td>
      <td>big</td>
      <td>low</td>
      <td>unacc</td>
    </tr>
    <tr>
      <th>1117</th>
      <td>med</td>
      <td>med</td>
      <td>3</td>
      <td>4</td>
      <td>small</td>
      <td>med</td>
      <td>acc</td>
    </tr>
    <tr>
      <th>541</th>
      <td>high</td>
      <td>high</td>
      <td>2</td>
      <td>2</td>
      <td>small</td>
      <td>med</td>
      <td>unacc</td>
    </tr>
  </tbody>
</table>
</div>




```python
cars.doors.replace(('5more'),('5'),inplace=True)
cars.capacity.replace(('more'),('5'),inplace=True)
```


```python
cars.describe()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
    
    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>buying</th>
      <th>maint</th>
      <th>doors</th>
      <th>capacity</th>
      <th>lug_boot</th>
      <th>safety</th>
      <th>class</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>count</th>
      <td>1728</td>
      <td>1728</td>
      <td>1728</td>
      <td>1728</td>
      <td>1728</td>
      <td>1728</td>
      <td>1728</td>
    </tr>
    <tr>
      <th>unique</th>
      <td>4</td>
      <td>4</td>
      <td>4</td>
      <td>3</td>
      <td>3</td>
      <td>3</td>
      <td>4</td>
    </tr>
    <tr>
      <th>top</th>
      <td>med</td>
      <td>med</td>
      <td>2</td>
      <td>2</td>
      <td>med</td>
      <td>med</td>
      <td>unacc</td>
    </tr>
    <tr>
      <th>freq</th>
      <td>432</td>
      <td>432</td>
      <td>432</td>
      <td>576</td>
      <td>576</td>
      <td>576</td>
      <td>1210</td>
    </tr>
  </tbody>
</table>
</div>



The count for every feature is the same as the number of rows, which indicates no missing values.  
Yay!  
Since we are dealing with categorical data, we are shown the distinct values in the unique column.

The distribution of the acceptability of the cars.


```python
#Lets find out the number of cars in each evaluation category
cars['class'].value_counts()
```




    unacc    1210
    acc       384
    good       69
    vgood      65
    Name: class, dtype: int64




```python
sns.countplot(cars['class'])
```




![png](/images/car_value/output_11_1.png)


As we can see, our target varible is highly skewed

## Initial Feature Exploration

So we need to predict the acceptability of the car given the 6 features. Let’s try to find the relationship between each feature variable with the target variable. I’ll use pandas crosstab to make a table showing the relationship and Plotly to plot an interactive graph for the same.


```python
buy = pd.crosstab(cars['buying'], cars['class'])
maint = pd.crosstab(cars['maint'], cars['class'])
drs = pd.crosstab(cars['doors'], cars['class'])
prsn = pd.crosstab(cars['capacity'], cars['class'])
lb = pd.crosstab(cars['lug_boot'], cars['class'])
sfty = pd.crosstab(cars['safety'], cars['class'])
```


```python
buy
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }
    
    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th>class</th>
      <th>acc</th>
      <th>good</th>
      <th>unacc</th>
      <th>vgood</th>
    </tr>
    <tr>
      <th>buying</th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>high</th>
      <td>108</td>
      <td>0</td>
      <td>324</td>
      <td>0</td>
    </tr>
    <tr>
      <th>low</th>
      <td>89</td>
      <td>46</td>
      <td>258</td>
      <td>39</td>
    </tr>
    <tr>
      <th>med</th>
      <td>115</td>
      <td>23</td>
      <td>268</td>
      <td>26</td>
    </tr>
    <tr>
      <th>vhigh</th>
      <td>72</td>
      <td>0</td>
      <td>360</td>
      <td>0</td>
    </tr>
  </tbody>
</table>
</div>




```python
buy.plot.bar(stacked=True)
```




![png](/images/car_value/output_17_1.png)



```python
maint.plot.bar(stacked=True)
```


![png](/images/car_value/output_18_1.png)



```python
drs.plot(kind='bar',stacked=True)
```



![png](/images/car_value/output_19_1.png)



```python
sfty.plot.bar(stacked=True)
```




![png](/images/car_value/output_20_1.png)

## Encoding and Data Spliting

We need to encode the categorical data
There are two options, either we use label encoder or one hot encoder.
Intuitively, predictors' value in the dataset such as 'low, med, high' introduce an underlying linear order itself, therefore, it's alright to transform data with ordinal encoder.


```python
cars1 = cars.copy()
cars1['class'].replace(('unacc', 'acc', 'good', 'vgood'), (1, 2, 3,4), inplace = True)
cars1['buying'].replace(('vhigh', 'high', 'med', 'low'), (4,3, 2, 1), inplace = True)
cars1['maint'].replace(('vhigh', 'high', 'med', 'low'), (4,3, 2, 1), inplace = True)
cars1['lug_boot'].replace(('small','med','big'),(1,2,3),inplace=True)
cars1['safety'].replace(('low','med','high'),(1,2,3),inplace=True)
```


```python
print("Feature Correlation:\n")

fig, ax = plt.subplots(figsize=(9,7))
ax.set_ylim(6.0, 0)

ax=sns.heatmap(cars1.corr(),center=0,vmax=.3,cmap="YlGnBu",
            square=True, linewidths=.5, annot=True)
```

    Feature Correlation:




![output_24_1.png](https://i.loli.net/2020/02/27/21gvpwnOc6FZaQ4.png)



Ignoring the diagonal values, it can be seen that most of the columns shows very weak correlation with 'class'. 'safety' column is having a correlation with 'class'.


```python
#Dividing the dataframe into x features and y target variable
X1 = cars1.drop(['class'],axis = 1)
y1 = cars1['class']
```


```python
from sklearn.model_selection import train_test_split
X1_train, X1_test, y1_train, y1_test = train_test_split(X1, y1, test_size=0.3, random_state=42)
```


```python
X3 = cars.drop(['class'],axis = 1)
y3 = y1
# Using pandas dummies function to encode categorical data

X3 = pd.get_dummies(X3,columns= ['buying','capacity','doors','maint','lug_boot'],
                    prefix_sep='_', drop_first=True)
X3['safety'].replace(('low','med','high'),(0,1,2),inplace=True)

X3_train, X3_test, y3_train, y3_test = train_test_split(X3, y3, test_size = 0.3, random_state = 41)
```

<br>

## Model Building

### KNN


```python
from __future__ import print_function
from sklearn.metrics import classification_report
from sklearn.model_selection import GridSearchCV

from sklearn.neighbors import KNeighborsClassifier


#create a dictionary of all values we want to test for n_neighbors
param_grid = {'n_neighbors': np.arange(1,15)}

scores = ['precision', 'recall']
for score in scores:
    print("# Tuning hyper-parameters for %s" % score)
    print()

    knn_gscv = GridSearchCV(KNeighborsClassifier(), param_grid, cv=5, scoring='%s_micro' % score)
    knn_gscv.fit(X1_train, y1_train)

    print("Best parameters set found on development set:\n")

    print(knn_gscv.best_params_)
    print("\nGrid scores on development set:\n")

    means = knn_gscv.cv_results_['mean_test_score']
    stds = knn_gscv.cv_results_['std_test_score']

    print("\nDetailed classification report:")
    print("\nThe model is trained on the full development set.")
    print("\nThe scores are computed on the full evaluation set.\n")

    y_true, y_pred = y1_test, knn_gscv.predict(X1_test)
    print(classification_report(y_true, y_pred))
```

               		precision    recall  f1-score   support
               1       0.97      0.99      0.98       358
               2       0.90      0.88      0.89       118
               3       0.78      0.74      0.76        19
               4       0.89      0.67      0.76        24
    
        accuracy                           0.94       519
       macro avg       0.88      0.82      0.85       519
    weighted avg       0.94      0.94      0.94       519



```python
# Plot K vs accuracy
avg_score=[]
for k in range(2,15):
    knn=KNeighborsClassifier(n_neighbors=k)
    score=cross_val_score(knn,X1_train,y1_train,cv=5,scoring='accuracy')
    avg_score.append(score.mean())

plt.figure(figsize=(8,5))
plt.plot(range(2,15),avg_score)
plt.xlabel("n_neighbours")
plt.ylabel("accuracy")
plt.title("K value vs Accuracy Plot")
```




![png](/images/car_value/output_44_1.png)


Both grid search cross validation and plot show that neighbor = 5 is a potential good hyperparameter.




```python
#Using KNN classifier,

knn = KNeighborsClassifier(n_neighbors = 5, metric = 'minkowski', p = 2)
knn.fit(X1_train, y1_train)

y1_pred = knn.predict(X1_test)
f1_KNN = f1_score(y1_test,y1_pred, average='micro')

print("Training Accuracy: ",knn.score(X1_train, y1_train))
print("Testing Accuracy: ", knn.score(X1_test, y1_test))
print("Cross-Validation Score :{0:.3f}".format(np.mean(cross_val_score(knn, X1, y1, cv=5))))
```

    Training Accuracy:  0.9818031430934657
    Testing Accuracy:  0.9421965317919075
    Cross-Validation Score :0.813

### SVM Grid Search


```python
from sklearn.metrics import classification_report
from sklearn.model_selection import GridSearchCV

from sklearn.svm import SVC

# Set the parameters by cross-validation
parameters = [{'kernel': ['rbf'],
               'gamma': 10. ** np.arange(-5, 4),
               'C': [0.1, 1, 10, 100, 1000]},
              {'kernel': ['linear'],
               'C': [0.1,  1, 10, 100, 1000]}]

scores = ['precision', 'recall']
for score in scores:
    print("# Tuning hyper-parameters for %s" % score)
    print()

    svc_gscv = GridSearchCV(SVC(), parameters, cv=5, scoring='%s_micro' % score)

    svc_gscv.fit(X1_train, y1_train)

    print("Best parameters set found on development set:\n")

    print(svc_gscv.best_params_)
    print("\nGrid scores on development set:\n")

    means = svc_gscv.cv_results_['mean_test_score']
    stds = svc_gscv.cv_results_['std_test_score']
    print("\nDetailed classification report:")
    print("\nThe model is trained on the full development set.")
    print("\nThe scores are computed on the full evaluation set.\n")

    y_true, y_pred = y1_test, svc_gscv.predict(X1_test)
    print(classification_report(y_true, y_pred))
```

    # Tuning hyper-parameters for precision
    
    Best parameters set found on development set:
    
    {'C': 100, 'gamma': 0.1, 'kernel': 'rbf'}
    
    Grid scores on development set:
    
    Detailed classification report:
        
        The model is trained on the full development set.
        
        The scores are computed on the full evaluation set.
        
                      precision    recall  f1-score   support
        
                   1       0.99      0.99      0.99       358
                   2       0.96      0.95      0.95       118
                   3       0.85      0.89      0.87        19
                   4       0.92      0.92      0.92        24
        
            accuracy                           0.97       519
           macro avg       0.93      0.94      0.93       519
        weighted avg       0.98      0.97      0.98       519
    
    # Tuning hyper-parameters for recall   
        Best parameters set found on development set:    
        {'C': 100, 'gamma': 0.1, 'kernel': 'rbf'}
     
     Grid scores on development set:
      
     Detailed classification report:
                      precision    recall  f1-score   support
                   1       0.99      0.99      0.99       358
                   2       0.96      0.95      0.95       118
                   3       0.85      0.89      0.87        19
                   4       0.92      0.92      0.92        24
        
            accuracy                           0.97       519
           macro avg       0.93      0.94      0.93       519
        weighted avg       0.98      0.97      0.98       519

 

### Fit SVC rbf

From the GridSearch result, we find that with `kernel = 'rbf', C = 100, gamma = 0.1`, the model can achive best performance with respect to recall and accuracy. Since the unbalanced label of our target, I decide to go with recall, intuitively because we want to capture as many cars that will not be accepted as possible.


```python
from sklearn.svm import SVC

svc_rbf = SVC(kernel = 'rbf', C = 100, gamma = 0.1)
svc_rbf.fit(X1_train,y1_train)
y1_pred = svc_rbf.predict(X1_test)
f1_SVC_rbf = f1_score(y1_test,y1_pred, average='micro')

print("Training Accuracy: ",svc_rbf.score(X1_train, y1_train))
print("Testing Accuracy: ", svc_rbf.score(X1_test, y1_test))
print("Cross-Validation Score :{0:.3f}".format(np.mean(cross_val_score(svc_rbf, X1, y1, cv=5))))

```

    Training Accuracy:  0.9983457402812241
    Testing Accuracy:  0.9749518304431599
    Cross-Validation Score :0.877



#### Learning curve


```python
from sklearn.model_selection import learning_curve
from sklearn.svm import SVC

plt.figure()
plt.xlabel("Training examples")
plt.ylabel("Score")
train_sizes, train_scores, test_scores = learning_curve(
        svc_rbf, X1_train, y1_train, cv=5, n_jobs=1)

train_scores_mean = np.mean(train_scores, axis=1)
train_scores_std = np.std(train_scores, axis=1)
test_scores_mean = np.mean(test_scores, axis=1)
test_scores_std = np.std(test_scores, axis=1)

plt.grid()
plt.title("Learning Curves (SVM, RBF kernel,C=100, $\gamma=0.1$)")
plt.fill_between(train_sizes, train_scores_mean - train_scores_std,
                     train_scores_mean + train_scores_std, alpha=0.1,
                     color="r")
plt.fill_between(train_sizes, test_scores_mean - test_scores_std,
                     test_scores_mean + test_scores_std, alpha=0.1, color="g")
plt.plot(train_sizes, train_scores_mean, 'o-', color="r",label="Training score")
plt.plot(train_sizes, test_scores_mean, 'o-', color="g", label="Cross-validation score")

plt.legend(loc="best")

plt.show()
```


![png](/images/car_value/output_55_0.png)

### Decision Tree

1. ind Hyperparameter


```python
# Plot max_depth vs accuracy

from sklearn.tree import DecisionTreeClassifier

avg_train=[]
avg_test=[]

for max_depth in range(2,11):
    dtree = DecisionTreeClassifier(max_depth=max_depth)
    train_score=cross_val_score(dtree,X1_train,y1_train,cv=5,scoring='accuracy')
    test_score =cross_val_score(dtree,X1_test,y1_test,cv=5,scoring='accuracy')
    avg_train.append(train_score.mean())
    avg_test.append(test_score.mean())

plt.figure(figsize=(8,5))
plt.plot(range(2,11), avg_train,color="r",label="Training score")
plt.plot(range(2,11), avg_test, color="g", label="Test score")
plt.legend()
plt.xlabel("max_depth")
plt.ylabel("accuracy")
```




![png](/images/car_value/output_61_1.png)


Max depth of 9 looks to be a balanced cutoff point

2. Fit the model


```python
#Trying decision tree classifier
dtree = DecisionTreeClassifier(random_state = 0, max_depth=9)
dtree.fit(X1_train, y1_train)
```


```python
y1_pred = dtree.predict(X1_test)
F1_dtree = f1_score(y1_test,y1_pred, average='micro')

print("Training Accuracy: ",dtree.score(X1_train, y1_train))
print("Testing Accuracy: ", dtree.score(X1_test, y1_test))

cm = confusion_matrix(y1_test, y1_pred)
print('\n',cm,'\n')
```

    Training Accuracy:  0.9842845326716294
    Testing Accuracy:  0.9556840077071291

### Random Forest

####  Baseline Model


```python
from sklearn.ensemble import RandomForestClassifier

rfc=RandomForestClassifier(random_state=51)

rfc.fit(X1_train,y1_train)
y1_pred = rfc.predict(X1_test)

print("Training Accuracy: ",rfc.score(X1_train, y1_train))
print("Testing Accuracy: ", rfc.score(X1_test, y1_test))
```

    Training Accuracy:  1.0
    Testing Accuracy:  0.9402697495183044

So, the basic model of RFC is giving 94% accuracy, but training score is clearly overfit. Now, check the effect of n_estimators on the model

#### Fine Tune Hyperparameter


```python
# Plot number of trees vs accuracy
n_tree=[10,25,50,100]
curve = validation_curve(rfc,X1_train,y1_train,cv=5,param_name='n_estimators',    param_range=n_tree)
train_score=[curve[0][i].mean() for i in range (0,len(n_tree))]
test_score=[curve[1][i].mean() for i in range (0,len(n_tree))]

f,ax=plt.subplots(1)
plt.plot(n_tree,train_score)
plt.plot(n_tree,test_score)
plt.xticks=n_tree

plt.xlabel("n_estimators")
plt.ylabel("accuracy")
plt.title("number of trees vs Accuracy Plot")
```



<img src='/images/car_value/output_71_1.png' width="200")


So, with the increasing n_estimators, test accuracy is increasing. Model is evaluating best at n_estimators=50. After n_estimators = 50, model starts overfitting.
Now, we've reached approx. 97.1% accuracy.

Now, check how the model fits for various values of 'max_features'


```python
rfc = RandomForestClassifier(n_estimators=50,random_state=51)
rfc.fit(X1_train,y1_train)
```


```python
param_range=range(1,len(X1.columns)+1)
curve=validation_curve(RandomForestClassifier(n_estimators=50,random_state=51),X1_train,y1_train,cv=5,
    param_name='max_features',param_range=param_range)

train_score=[curve[0][i].mean() for i in range (0,len(param_range))]
test_score=[curve[1][i].mean() for i in range (0,len(param_range))]
f, ax = plt.subplots(1,figsize=(5,5))
plt.plot(param_range,train_score, label='training')
plt.plot(param_range,test_score,label='test')
plt.xticks=param_range
plt.legend()
plt.title('validation_curve of random forest with 50 trees')
```




![png](/images/car_value/output_75_1.png)

#### Deal with overfitting

From above graph, it is clear that model is giving best resut for max_features=5. Still the model is overfitting.

Now we've reached 97.2% accuracy approx.

We can also check of other parameters like 'max_depth','criterion',etc using above code.Another simple way is to use GridSearch to get combination of best parameters. As this dataset is small, GridSearch will take less time to complete.


```python
param_grid={'criterion':['gini','entropy'],
           'max_depth':[2,5,10,20],
           'max_features':[2,4,5,6,'auto'],
           'max_leaf_nodes':[2,3,None],}

grid=GridSearchCV(estimator=RandomForestClassifier(n_estimators=50,random_state=51),
                  param_grid=param_grid,cv=10)

grid.fit(X1_train,y1_train)

print(grid.best_params_)
print(grid.best_score_)
F1_rfc = f1_score(y1_test,grid.fit(X1_train,y1_train).predict(X1_test), average='micro')
```

    {'criterion': 'entropy', 'max_depth': 20, 'max_features': 6, 'max_leaf_nodes': None}
    0.9859387923904053


So, with above parameters for random forest model, we've reached 98.6% accuracy.


```python
curve=learning_curve(RandomForestClassifier(n_estimators=50,
                                         criterion='entropy',
                                         max_features=6,
                                         max_depth=20,
                                         random_state=51,max_leaf_nodes=None),
                  X1_train,y1_train, cv=5)

size=curve[0]
train_score=[curve[1][i].mean() for i in range (0,5)]
test_score=[curve[2][i].mean() for i in range (0,5)]
fig=plt.figure(figsize=(6,4))
plt.plot(size,train_score)
plt.plot(size,test_score)
```

![png](/images/car_value/output_80_1.png)



Model is overfitting as train accuracy is 1 ,but test accuracy is much less.

I've already tried changing RFC parameters to tackle overfitting. But, still it is not reduced.To reduce variance, we can
1. Increase number of samples. (It is clear from above graph that incresing number of samples will improve model)
2. Reduce number of features



#### Feature Reduction


```python
feature_import = pd.DataFrame([rfc.feature_importances_], columns=X1.columns)

print(feature_import)
```

         buying     maint     doors  capacity  lug_boot    safety
    0  0.154819  0.151853  0.059702  0.251283  0.094677  0.287667


From feature importances, it is clear that 'doors' feature is least important.
So, train our model excluding that feature.


```python
X1_train_new, X1_test_new, y1_train_new, y1_test_new = train_test_split(
    X1[['buying', 'maint', 'capacity', 'lug_boot', 'safety']],
    y1, test_size=0.3, random_state=42)
```


```python
rfc1=RandomForestClassifier(n_estimators=50,criterion='entropy',max_features=4,max_depth=10,random_state=51,
    max_leaf_nodes=None)
rfc1.fit(X1_train_new,y1_train_new)
rfc1.score(X1_test_new,y1_test_new)
```


    0.930635838150289



Our data already has less features and even if we drop the least important feature, then also the accuracy is reducing to 93.06%

So, dropping a feature is not an option to reduce variance in our model.The only option we are left with is to get more data.

Conclusion:
Random Forest Classifier is the best suitable model for this data with following parameters:
n_estimators: 50
criterion: entropy
max_depth: 10
max_features: 4
max_leaf_nodes: None

We are able to achieve 98.6% accuracy with this model

## Model Comparison 


```python
models=['rbf SVC','Logistic Regression','Decision Tree','Naive Bayes','Random Forest']
f1 = np.array([f1_SVC_rbf, f1_LR, F1_dtree,f1_gnb,F1_rfc])

y_pos = np.arange(len(models))
plt.barh(y_pos, f1)
plt.yticks(y_pos, ('rbf SVC','Logistic Regression','Decision Tree','Naive Bayes','Random Forest'))
plt.show()
```


![png](/images/car_value/output_90_0.png)

```python
score = pd.DataFrame([f1],columns=models)
score
```


<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }


</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: left;">
      <th>rbf SVC</th>
      <th>Logistic Regression</th>
      <th>Decision Tree</th>
      <th>Naive Bayes</th>
      <th>Random Forest</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0.974</td>
      <td>0.81</td>
      <td>0.96</td>
      <td>0.76</td>
      <td>0.986</td>
    </tr>
  </tbody>
</table>

</div>



__Conclusion__
SVM rbf Classifier and Random Forest are roughly equally suitable models for this classification context, however, be aware that Random Forest tends to show overfitting, and accuracy won't get better with trees growing or features reduction.

We are able to achieve 98.6% weighted accuracy with this model.





-- END --

