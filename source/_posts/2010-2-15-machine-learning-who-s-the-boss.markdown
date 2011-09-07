---
layout: post
title: Machine Learning - Who's the Boss?
date: 2010-02-15 15:48:42 -0500
comments: true
---

In the Machine Learning field, there are two types of algorithms that can be applied to a set of data to solve different kinds of problems: _Supervised_ and _Unsupervised_ learning algorithms. Both of these have in common that they aim to extract information or gain knowledge from the raw data that would otherwise be very hard and unpractical to do. This is because we live in very dynamic environments with changing parameters and vast amounts of data being gathered. This data hides important patterns and correlations that are sometimes impossible to deduce manually, and where computing power and smart algorithms excel. They are also heavily dependent on the quantity and quality of the input data, and as such, evolve in their output and accuracy as more and better input data becomes available.

In this article we will walk through what constitues Supervised and Unsupervised Learning. An overview of the language and terms is presented, as well as the general workflow used for machine learning tasks.

### Supervised Learning

In supervised machine learning we have a set of data points or _observations_ for which we know the desired output, class, _target variable_  or _outcome_. The outcome may take one of many values called _classes_ or _labels_. A classic example is that given a few thousand emails for which we know whether they are spam or ham (their labels), the idea is to create a model that is able to deduce whether new, unsean emails are spam or not. In other words, we are creating a mapping function where the inputs are the email's sender, subject, date, time, body, attachments and other attributes, and the output is a prediction as to whether the email is spam or ham. The _target variable_ is in fact providing some level of *supervision* in that it is used by the learning algorithm to adjust parameters or make decisions that will allow it to predict labels for new data. Finally of note, when the algorithm is predicting labels of observations we call it a _classifier_. Some classifiers are also capable of providing a probability of a data point belonging to class in which case it is often referred to a probabilistic model or a regression - not to be confused with a [statistical regression model](http://en.wikipedia.org/wiki/Regression_analysis#Regression_models).

Lets take this as an example in supervised learning algorithms. Given the following dataset, we want to predict on new emails whether they are spam or not. In the dataset below, note that the last column, `Spam?`, contains the labels for the examples.

<table>
  <thead>
    <td><b>Subject</b></td> <td><b>Date</b></td> <td><b>Time</b></td> <td><b>Body</b></td> <td><b>Spam?</b></td>
  </thead>
  <tbody>
    <tr> <td>I has the viagra for you</td> <td>03/12/1992</td> <td>12:23 pm</td> <td>Hi! I noticed that you are a software engineer <br/>so here's the pleasure you were looking for...</td> <td>Yes</td> </tr>
    <tr> <td>Important business</td> <td>05/29/1995</td> <td>01:24 pm</td> <td>Give me your account number and you'll be rich. </ br> I'm totally serial</td> <td>Yes</td> </tr>
    <tr> <td>Business Plan</td> <td>05/23/1996</td> <td>07:19 pm</td> <td>As per our conversation, here's the business plan for our new venture </ br> Warm regards...</td> <td>No</td> </tr>
    <tr> <td>Job Opportunity</td> <td>02/29/1998</td> <td>08:19 am</td> <td>Hi <name>!</ br>I am trying to fill a position for a PHP ... </td> <td>Yes</td> </tr>
    <tr> <td colspan="5"> [A few thousand rows ommitted] </td> </tr>
    <tr> <td>Call mom</td> <td>05/23/2000</td> <td>02:14 pm</td> <td>Call mom. She's been trying to reach you for a few days now</td> <td>No</td> </tr>
  </tbody>
</table>

A common workflow approach, and one that I've taken for supervised learning analysis is shown in the diagram below:

<img src="http://img.skitch.com/20100213-djhg1re7gaj83ngygcqgj1jm2d.png">

The process is:

1. _Scale and prepare training data_: First we build input vectors that are appropriate for feeding into our supervised learning algorithm.
2. _Create a training set and a validation set_ by randomly splitting the universe of data. The training set is the data that the classifier uses to learn how to classify the data, whereas the validation set is used to feed the already trained model in order to get an error rate (or other measures and techniques) that can help us identify the classifier's performance and accuracy. Typically you will use more training data (maybe 80% of the entire universe) than validation data. Note that there is also [cross-validation](http://en.wikipedia.org/wiki/Cross-validation_(statistics)), but that is beyond the scope of this article.
3. _Train the model_. We take the training data and we feed it into the algorithm. The end result is a model that has learned (hopefully) how to predict our outcome given new unknown data.
4. _Validation and tuning_: After we've created a model, we want to test its accuracy. It is critical to do this on data that the model has not seen yet - otherwise you are cheating. This is why on step 2 we separated out a subset of the data that was not used for training. We are indeed testing our model's generalization capabilities. It is very easy to learn every single combination of input vectors and their mappings to the output as observed on the training data, and we can achieve a very low error in doing that, but how does the very same rules or mappings perform on new data that may have different input to output mappings? If the classification error of the validation set is very big compared to the training set's, then we have to go back and adjust model parameters. The model will have essentially memorized the answers seen in the training data, loosing its generalization capabilities. This is called [_overfitting_](http://en.wikipedia.org/wiki/Overfitting), and there are various techniques for overcoming it.
5. Validate the model's performance. There are numerous techniques for achieving this, such as [ROC analysis](http://en.wikipedia.org/wiki/Receiver_operating_characteristic) and many others. The model's accuracy can be improved by changing its structure or the underlying training data. If the model's performance is not satisfactory, change model parameters, inputs and or scaling, go to step 3 and try again.
6. Use the model to classify new data. In production. Profit!

### Unsupervised Learning

The kinds of problems that are suited for unsupervised algorithms may seem similar, but are very different to supervised learners. Instead of trying to predict a set of known classes, we are trying to identify the patterns inherent in the data that separate like observations in one way or another. Viewed from 20 thousand feet, the main difference is that we are not providing a target variable like we did in supervised learning.

This marks a fundamental difference in how both types of algorithms operate. On one hand, we have supervised algorithms which try to minimize the error in classifying observations, while unsupervised learning algorithms don't have such luxuries because there are no outcomes or labels. Unsupervised algorithms try to create clusters of data that are inherently similar. In some cases we don't necessarily know what makes them similar, but the algorithms are capable of finding these relationships between data points and group them in significant ways. While supervised algorithms aim to minimize the classification error, unsupervised algorithms aim to create groups or subsets of the data where data points belonging to a cluster are as similar to each other as possible, while making the difference between the clusters as high as possible.

Another main difference is that in a clustering problem, the concept of "Training Set" does not apply in the same way as with supervised learners. Typically we have a dataset that is used to find the relationships in the data that buckets them in different clusters. We could of course apply the same clustering model to new data, but unless it is too unpractical to do so (perhaps for performance reasons), we will most certainly want to rerun the algorithm on new data as it will typically find new relationships within the data that may surface up given the new observations.

As a simple example, you could imagine clustering customers by their demographics. The learning algorithm may help you discover distinct groups of customers by region, age ranges, gender and other attributes in such way that we can develop targeted marketing programs. Another example may be to cluster patients by their chronic diseases and comorbidities in such a way that targeted interventions can be developed to help manage their diseases and improve their lifestyles.

<img src="http://img.skitch.com/20100215-qm59id21fs2kr2m1r2sc5umwgw.png">

For unsupervised learning, the process is:

1. _Scale and prepare raw data_: As with supervised learners, this step entails selecting features to feed into our algorithm, and scaling them to build a suitable data set.
2. _Build model_: We run the unsupervised algorithm on the scaled dataset to get groups of like observations.
3. _Validate_: After clustering the data, we need to verify whether it cleanly separated the data in significant ways. This includes calculating a set of statistics on the resulting clusters (such as the within group sum of squares), as well as analysis based on domain knowledge, where you may measure how certain attributes behave when aggregated by the clusters. 
4. Once we are satisfied with the clusters created there is no need to run the model with new data (although you can). Profit!

#### Step zero

A common step that I have not outlined above and should be performed when working on any such problem is to get a strong understanding for the characteristics of the data. This should be a combination of visual analysis (for which I prefer the excellent [ggplot2](http://had.co.nz/ggplot2/) library) as well as some basic descriptive statistics and data profiling such as quartiles, means, standard deviation, frequencies and others. [R](http://www.r-project.org)'s [Hmisc](http://cran.r-project.org/web/packages/Hmisc/index.html) package has a great function for this purpose called [`describe`](http://lib.stat.cmu.edu/S/Harrell/help/Hmisc/html/describe.html). 

I am convinced that not performing this step is a non starter for any datamining project. It will allow you to identify missing values, general distributions of data, early outlier detection, among many other characteristics that drive the selection of attributes for your models.

### Wrapping up

<a href="http://televixen.files.wordpress.com/2009/02/wtb.jpg"><img src="http://televixen.files.wordpress.com/2009/02/wtb.jpg"></a>

This is certainly quite a bit of info, especially if these terms are new to you. To summarize:

<table>
  <thead>
    <tr>
      <td></td>
      <td><b>Supervised Learning</b></td>
      <td><b>Unsupervised Learning</b></td>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>Objective</b></td>
      <td>Classify or predict a class.</td>
      <td>Find patterns inherent to the data, creating cluster of like data points. <a href="http://en.wikipedia.org/wiki/Dimension_reduction">Dimensionality Reduction</a>.</td>
    </tr>
    <tr>
      <td><b>Example Implementations</b></td>
      <td>Neural Networks (<a href="http://en.wikipedia.org/wiki/Multilayer_perceptron">Multilayer Perceptrons</a>, <a href="http://en.wikipedia.org/wiki/Radial_basis_function_network">RBF Networks</a> and others, <a href="http://en.wikipedia.org/wiki/Support_vector_machine">Support Vector Machines</a>, Decision Trees (<a href="http://en.wikipedia.org/wiki/ID3_algorithm">ID3</a>, <a href="http://en.wikipedia.org/wiki/C4.5_algorithm">C4.5</a> and others), <a href="http://en.wikipedia.org/wiki/Naive_Bayes_classifier">Naive Bayes Classifiers</a>...</td>
      <td><a href="http://en.wikipedia.org/wiki/K-means_clustering">K-Means</a> (and variants), <a href="http://en.wikipedia.org/wiki/Cluster_analysis#Hierarchical_clustering">Hierarchical Clustering</a>, <a href="http://en.wikipedia.org/wiki/Self-organizing_map">Kohonen Self Organizing Maps</a>...</td>
    </tr>
    <tr>
      <td><b>Who's the Boss?</b></td>
      <td>The target variable or outcome.</td>
      <td>The relationships inherent to the data.</td>
    </tr>
  </tbody>
</table>

Hopefuly this article shows the main differences between Unsupervised and Supervised Learning. On followup posts we will dig into some of the specific implementations of these algorithms with examples in [R](http://www.r-project.org) and [Ruby](http://ruby-lang.org)
