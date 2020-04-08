---
layout:     post
title:      Cats vs Dogs Classification
description:  Binary Image Classification with Keras and Transfer Learning
date:       2019-11-28
featuredImage: "/images/post-cat-dog.jpg"
author:     Nina
catalog: 	 true
comment: true
toc: true
tags: [machine learning, neural network]
---



# Image classification exercise



I'm not gonna lie. I'm more of a dog person. Better know how to tell the difference. 😂 Here we go.



## Introduction

This is an Image classification exercise. I will play with an expired Kaggle competition. The code is available in a jupyter notebook here. You will need to download the data from the Kaggle competition. https://www.kaggle.com/c/dogs-vs-cats/. The dataset contains 25,000 images of dogs and cats (12,500 from each class). I will create a new dataset containing 3 subsets, a training set with 16,000 images, a validation dataset with 4,500 images and a test set with 4,500 images.

I will first build a vanilla CNN model as the baseline. And then apply transfter learning to further improve the performance.

Keras comes prepackaged with many types of these pretrained models. Some of them are:

- VGGNET : Introduced by Simonyan and Zisserman in their 2014 paper, Very Deep Convolutional Networks for Large Scale Image Recognition.
- RESNET : First introduced by He et al. in their 2015 paper, Deep Residual Learning for Image Recognition
- INCEPTION: The “Inception” micro-architecture was first introduced by Szegedy et al. in their 2014 paper, Going Deeper with Convolutions:

and more. Detailed explanation of some of these architectures can be found [here](https://www.pyimagesearch.com/2017/03/20/imagenet-vggnet-resnet-inception-xception-keras/).



## Start here

```python
import numpy as np
import pandas as pd
import os, shutil
import random

import keras
from keras.preprocessing import image
from keras.preprocessing.image import ImageDataGenerator
from keras.utils import to_categorical
from sklearn.model_selection import train_test_split

import cv2
import matplotlib.pyplot as plt
import seaborn as sns
%matplotlib inline
%config InlineBackend.figure_format = 'retina'
```


```python
PATH = '../input/'
train_dir = '../input/train/'
test_dir = '../input/test/'
```

## Prepare data

```python
train_images = []
train_labels = []

for img in os.listdir(train_dir):
    try:
        img_r = cv2.imread(os.path.join(train_dir, img), cv2.IMREAD_COLOR)
        train_images.append(np.array(cv2.resize(img_r, (150, 150), interpolation = cv2.INTER_CUBIC)))
        if 'dog' in img:
            train_labels.append(1)
        else:
            train_labels.append(0)
    except Exception as e:
        print('broken image')
```

    broken image



```python
plt.title(train_labels[0])
plt.imshow(train_images[0])
```

<img src='/images/cat-dog/output_7_1.png' width="200">


```python
train_df = pd.DataFrame({ 'train_images':train_images,
                         'train_labels':train_labels})
sns.set(style="darkgrid")
ax = sns.countplot(x="train_labels", data = train_df,palette="Set3")
num_dogs = train_df['train_labels'].sum()
print('We have {} cats and {} dogs to train with.'.format(train_df.shape[0]-num_dogs,num_dogs))
```

    We have 12500 cats and 12500 dogs to train with.


<img src='/images/cat-dog/output_8_1.png' width="200">


We have 12000 cats and 12000 dogs to train with, so the dataset is balanced.


```python
train_labels = np.array(train_labels)

X_train, X_test, y_train, y_test = train_test_split(train_images, train_labels, test_size=0.2, random_state=13)

X_train = np.array(X_train)
X_test = np.array(X_test)
print("Train Shape:{}".format(X_train.shape))
print("Test Shape:{}".format(X_test.shape))
```

    Train Shape:(20000, 150, 150, 3)
    Test Shape:(5000, 150, 150, 3)



```python
X_train = X_train.reshape(-1, 150, 150, 3)
X_test = X_test.reshape(-1, 150, 150, 3)
print("Training data shape : {0}".format(X_train.shape))
print("Training label shape : {0}".format(y_train.shape))
print("Valid data shape : {0}".format(X_test.shape))
print("Valid label shape : {0}".format(y_test.shape))
```

    Training data shape : (20000, 150, 150, 3)
    Training label shape : (20000,)
    Valid data shape : (5000, 150, 150, 3)
    Valid label shape : (5000,)



## The base CNN model


```python
from keras.models import Sequential
from keras import layers
from keras import optimizers
from keras import backend as K
from keras.layers import Dense, Activation, Dropout, Conv2D, MaxPooling2D, Flatten, BatchNormalization
from keras.applications import VGG16
```


```python
# Creating the convnet model
def build_cnn():
    model = Sequential()

    model.add(Conv2D(32, (3, 3), activation='relu', input_shape=(150, 150, 3)))
    model.add(BatchNormalization())
    model.add(MaxPooling2D(pool_size=(2, 2)))
    model.add(Dropout(0.25))

    model.add(Conv2D(64, (3, 3), activation='relu'))
    model.add(BatchNormalization())
    model.add(MaxPooling2D(pool_size=(2, 2)))
    model.add(Dropout(0.25))

    model.add(Conv2D(128, (3, 3), activation='relu'))
    model.add(BatchNormalization())
    model.add(MaxPooling2D(pool_size=(2, 2)))
    model.add(Dropout(0.25))

    model.add(Flatten())
    model.add(Dense(512, activation='relu'))
    model.add(BatchNormalization())
    model.add(Dropout(0.5))
    model.add(Dense(1, activation='sigmoid')) # 2 because we have cat and dog classes

    return model
```

## Fit the model


```python
model_base = build_cnn()
model_base.name = 'base_cnn'
model_base.summary()
```

    _________________________________________________________________
    Layer (type)                 Output Shape              Param #   
    =================================================================
    conv2d_1 (Conv2D)            (None, 148, 148, 32)      896       
    _________________________________________________________________
    batch_normalization_1 (Batch (None, 148, 148, 32)      128       
    _________________________________________________________________
    max_pooling2d_1 (MaxPooling2 (None, 74, 74, 32)        0         
    _________________________________________________________________
    dropout_1 (Dropout)          (None, 74, 74, 32)        0         
    _________________________________________________________________
    conv2d_2 (Conv2D)            (None, 72, 72, 64)        18496     
    _________________________________________________________________
    batch_normalization_2 (Batch (None, 72, 72, 64)        256       
    _________________________________________________________________
    max_pooling2d_2 (MaxPooling2 (None, 36, 36, 64)        0         
    _________________________________________________________________
    dropout_2 (Dropout)          (None, 36, 36, 64)        0         
    _________________________________________________________________
    conv2d_3 (Conv2D)            (None, 34, 34, 128)       73856     
    _________________________________________________________________
    batch_normalization_3 (Batch (None, 34, 34, 128)       512       
    _________________________________________________________________
    max_pooling2d_3 (MaxPooling2 (None, 17, 17, 128)       0         
    _________________________________________________________________
    dropout_3 (Dropout)          (None, 17, 17, 128)       0         
    _________________________________________________________________
    flatten_1 (Flatten)          (None, 36992)             0         
    _________________________________________________________________
    dense_1 (Dense)              (None, 512)               18940416  
    _________________________________________________________________
    batch_normalization_4 (Batch (None, 512)               2048      
    _________________________________________________________________
    dropout_4 (Dropout)          (None, 512)               0         
    _________________________________________________________________
    dense_2 (Dense)              (None, 1)                 513       
    =================================================================
    Total params: 19,037,121
    Trainable params: 19,035,649
    Non-trainable params: 1,472
    _________________________________________________________________



```python
from keras.optimizers import RMSprop
model_base.compile(loss = 'binary_crossentropy',
                   optimizer = optimizers.RMSprop(lr=1e-4),
                   metrics=['accuracy'])

# model_base.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])

history_base=model_base.fit(x=X_train, y=y_train, epochs=20, verbose=1,validation_data=(X_test, y_test))
```

```python
model_base.save_weights('model_base_wieghts.h5')
model_base.save('model_base.h5')
```

### Performance of base model


```python
loss = model_base.evaluate(x=X_test, y=y_test)[0]
acc = model_base.evaluate(x=X_test, y=y_test)[1]

print('Base CNN Model gives me LogLoss of {}'.format(loss))
print('Base CNN Model gives me Accuracy of {}'.format(acc))
```

    5000/5000 [==============================] - 2s 408us/step
    5000/5000 [==============================] - 2s 336us/step
    Base CNN Model gives me LogLoss of 0.5596861797451973
    Base CNN Model gives me Accuracy of 0.8514



```python
acc = history_base.history['acc']
val_acc = history_base.history['val_acc']
loss = history_base.history['loss']
val_loss = history_base.history['val_loss']

epochs = range(1, len(acc)+1)

fig, (ax1, ax2) = plt.subplots(1, 2,figsize=(12,6))
ax1.plot(epochs, loss, color='blue', label = 'Training loss')
ax1.plot(epochs, val_loss,color='green', label = 'Validation loss')
ax1.set_title('Training and Validation Accuracy')
ax1.legend()

ax2.plot(epochs, acc,  color='blue',label = 'Training acc')
ax2.plot(epochs, val_acc,color='green',label = 'Validation acc')
ax2.set_title('Training and Validation Accuracy')
ax2.legend()

plt.show()
```

<img src='/images/cat-dog/output_21_0.png'>

Obvious overfitting charastics and can't achieve good accuracy score. The reason might be we have limited dataset even we already include data agumentation in the CNN model.

To solve that, we can use transfer learning to take advantages of features from imagenet.

* There are two ways of using a pre-trained network:
    1. Running the convolutional base over our dataset, recording its output to a Numpy array on disk and then using this data as an input to a standalone, densely connected classifier
    2. Extending the model by adding a top layer and then training model
* The first method is cheap in terms of computation since it doesn't require you to train the model from scratch. For the same reason we cannot take advantage of Data Augmentation
* The second method involves training the network from scratch. This will help us exploit image augmentation, but for the same reason it will be computationally expensive

I will use the first type in this homework for the sake of time and computation ability as we have roughly enough data to train with.



## Transfer Learning VGG16

The loaded model is chopped after last max-pool layer in VGG16 architecture by setting the parameter `include_top=false`.


```python
# Defining and training the densely connected classifier

def model_transfer_vgg16_chopped():
    model = Sequential()   

    #model.add(ResNet50(include_top=False, pooling=POOLING))
    model.add(VGG16(include_top=False, weights='imagenet',  input_shape=(150,150,3)))

    model.add(layers.Flatten())
    model.add(layers.Dense(256, activation = 'relu'))
    model.add(layers.Dropout(0.5))
    model.add(layers.Dense(1,activation = 'sigmoid'))

    model.layers[0].trainable = False

    model.compile(optimizer=optimizers.RMSprop(lr=2e-5),
                  loss='binary_crossentropy',
                  metrics=['acc'])

    return model
```


```python
model_transfer = model_transfer_vgg16_chopped()
model_transfer.summary()
```

    Downloading data from https://github.com/fchollet/deep-learning-models/releases/download/v0.1/vgg16_weights_tf_dim_ordering_tf_kernels_notop.h5
    58892288/58889256 [==============================] - 2s 0us/step
    _________________________________________________________________
    Layer (type)                 Output Shape              Param #   
    =================================================================
    vgg16 (Model)                (None, 4, 4, 512)         14714688  
    _________________________________________________________________
    flatten_2 (Flatten)          (None, 8192)              0         
    _________________________________________________________________
    dense_3 (Dense)              (None, 256)               2097408   
    _________________________________________________________________
    dropout_5 (Dropout)          (None, 256)               0         
    _________________________________________________________________
    dense_4 (Dense)              (None, 1)                 257       
    =================================================================
    Total params: 16,812,353
    Trainable params: 2,097,665
    Non-trainable params: 14,714,688
    _________________________________________________________________



```python
print("The number of trainable weights before freezing the convolutional layer = ",len(model_transfer.trainable_weights))
```

    The number of trainable weights before freezing the convolutional layer =  4



```python
# set callbacks
from keras.callbacks import EarlyStopping, ReduceLROnPlateau

earlystop = EarlyStopping(monitor='val_loss',patience=3)

learning_rate_reduction = ReduceLROnPlateau(monitor='val_loss',
                                            patience=3,
                                            verbose=1,
                                            factor=0.5,
                                            min_lr=0.0001)

callbacks = [earlystop, learning_rate_reduction]
```


```python
history_vgg16 = model_transfer.fit(X_train, y_train,
                              validation_data=(X_test, y_test),
                              epochs = 20,
                             callbacks=callbacks,
                              verbose=1)
```

### Performance of transfer learning model

```python
model_transfer.evaluate(X_test, y_test)
```

    5000/5000 [==============================] - 7s 1ms/step





    [0.27564358766500857, 0.9672]




```python
model_transfer.save_weights('model_transfer_weights.h5')
model_transfer.save('model_transfer.h5')
```


```python
acc = history_vgg16.history['acc']
val_acc = history_vgg16.history['val_acc']
loss = history_vgg16.history['loss']
val_loss = history_vgg16.history['val_loss']

epochs = range(1, len(acc)+1)

fig, (ax1, ax2) = plt.subplots(1, 2,figsize=(12,6))
ax1.plot(epochs, loss,color='blue', label = 'Training loss')
ax1.plot(epochs, val_loss,color='red', label = 'Validation loss')
ax1.set_title('Training and Validation Log Loss')
ax1.legend()

ax2.plot(epochs, acc,  color='blue',label = 'Training acc')
ax2.plot(epochs, val_acc,color='red',label = 'Validation acc')
ax2.set_title('Training and Validation Accuracy')
ax2.legend()

plt.show()
```

<img src='/images/cat-dog/output_33_0.png'>


## Test

We will convert the predict category back into our generator classes by using train_generator.class_indices. It is the classes that image generator map while converting data into computer vision


```python
test_images = []
test_filenames = []
for img in os.listdir(test_dir):
    try:
        img_r = cv2.imread(os.path.join(test_dir, img), cv2.IMREAD_COLOR)
        test_images.append(np.array(cv2.resize(img_r, (150, 150), interpolation=cv2.INTER_CUBIC)))
        test_filenames.append(img.split('.')[0])
    except Exception as e:
        print('broken image')

test_filenames = [int(a) for a in test_filenames]
```

    broken image



```python
test_images = np.array(test_images)
test_images = test_images.reshape(-1, 150, 150, 3)
```


```python
predictions = model_transfer.predict(test_images)
```


```python
predictions2 = predictions.clip(min=0.005,max=0.995)
results = pd.DataFrame({"id": test_filenames, "label":list(predictions2)})
results['label'] = results['label'].map(lambda x: str(x).lstrip('[').rstrip(']')).astype(float)
```


```python
results.to_csv('submission.csv', index=False)
```


```python
for i in range(0,10):
    if predictions2[i, 0] >= 0.5:
        print('I am {:.3%} sure this is a Dog'.format(predictions[i][0]))
    else:
        print('I am {:.3%} sure this is a Cat'.format(1-predictions[i][0]))

    plt.imshow(test_images[i])
    plt.show()
```

    I am 100.000% sure this is a Dog


<img src='/images/cat-dog/output_41_1.png' width="200">

    I am 100.000% sure this is a Cat


<img src='/images/cat-dog/output_41_3.png' width="200">


    I am 100.000% sure this is a Cat

<img src='/images/cat-dog/output_41_5.png' width="200">


    I am 100.000% sure this is a Cat


<img src='/images/cat-dog/output_41_7.png' width="200">


    I am 100.000% sure this is a Dog


<img src='/images/cat-dog/output_41_9.png' width="200">


    I am 100.000% sure this is a Dog




My submission and score on Kaggle:
![image.png](https://i.loli.net/2019/11/24/9mMD6XVxj82ckqT.png)



codes available on [GitHub]( https://github.com/hyper-potato/cat-or-dog-deep-learning-keras)
