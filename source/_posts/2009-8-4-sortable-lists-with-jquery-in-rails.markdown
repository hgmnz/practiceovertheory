---
layout: post
title: Sortable lists with JQuery in Rails
date: 2009-08-07 01:35:30 -0400
comments: true
---

Drag 'n Drop sortable lists are a great way to provide a UI for sorting, well, lists of things. Most Rails examples [out](http://railscasts.com/episodes/147-sortable-lists) [in](http://blog.wyeworks.com/2009/7/27/drag-drop-sortable-lists) [the](http://harryche2008.wordpress.com/2008/07/19/how-to-do-ajax-style-drag-n-drop-sorting-with-rails/) [wild](http://www.devarticles.com/c/a/Ruby-on-Rails/Dropping-and-Sorting-with-AJAX-and-scriptaculous/2/) use prototype/scriptaculous and the built in Rails javascript helpers. In this walkthrough we'll provide the same functionality using JQuery instead. We will not be using the [built in Rails javascript helper](http://api.rubyonrails.org/classes/ActionView/Helpers/ScriptaculousHelper.html#M001640). Instead we'll write Unobstrusive Javascript using JQuery.

For this example we'll use a UserStory and a Task model:

<img src="http://yuml.me/diagram/scruffy/class/[UserStory]->[Task]." />

The very first step is to download JQuery into your Rails app, as well as some basic setup that will make our lives easier when dealing with Unobstrusive Javascript (UJS). UJS is overlooked amongst web app developers. It's all about separation of concerns. Remember in the late 80s and 90s when it was common to throw style right there on your HTML with things like <code>color="magenta"</code> or tags like <code><center></code>? Same thing is happening with Javascript: separate behavior from content and presentation. So instead of saying <code><a href="#" onclick="some_function()">foo</a></code>, you want to create a plain old link, and unobstrusively change the click's behavior via javascript. The basic feel for this looks like:

{% codeblock lang:html %}
<!-- in your view -->
<a id="foo" href="http://foo.info">This is foo!</a>
{% endcodeblock %}

{% codeblock lang:javascript %}
//in application.js (possibly)
$(document).ready(function(){
  $('#foo').click(function(){ 
    //handle the click
    return false; //cancel the browser's traditional event.
  });
});
{% endcodeblock %}

Just like we use CSS selectors to style an element, we can use JQuery selectors to describe the behavior of the element. Just like you may have <code>styles.css</code>, you may have <code>application.js</code>. This separation of behavior helps avoid cross browser inconsistencies, dry up and reuse your code, as well as provide graceful degradation to user agents that don't even support Javascript. For instance, a form may be submitted via AJAX if the browser supports Javascript, or the traditional action may execute if it doesn't. I've come to the point where looking at something like <code><a href="#" onclick='foo()'>foo</a></code> has the same effect as seeing style code in the middle of an HTML document: *repugnance*.

#### Set yourself up for JQuery

Head over to [the JQuery site](http://jquery.com/) and download the minified (production) version of JQuery. The sortable() function is part of [JQuery UI](http://jqueryui.com/home), which you can download from [here](http://jqueryui.com/download). Place both under public/javascripts and include it on your layouts. Pretty standard stuff.

Add a content block on your layout for <code>:javascript</code>. This pattern was picked up while hacking on the [bostonrb site's](http://bostonrb.org) [code](http://github.com/bostonrb/bostonrb/blob/bca256689a5e381b1a8e729a9769820322f44cfa/app/views/shared/_javascripts.html.haml#L2) and I've stolen it for my own projects. It is a great way to throw UJS in your views. This should be at the bottom of your layout, right before the closing <code></body></code> tag (or in it's own partial along with other javascript related stuffs):

{% codeblock lang:html %}
<html>
  <head><title>My boring blog</title></head>
  <body>
    ...
    yield :javascript
  </body>
</html>
{% endcodeblock %}

Having that out of the way, we need to set up jQuery's AJAX requests. We can use [JQuery's <code>$.ajaxSetup()</code>](http://docs.jquery.com/Ajax/jQuery.ajaxSetup) hook to set the appropriate headers. Additionally, we'll include Rails' authenticity token on our AJAX Post requests. 

For this to work, we need to store the Rails authenticity token *somewhere*. One option is to simply store it on a javascript variable as described [here](http://henrik.nyh.se/2008/05/rails-authenticity-token-with-jquery). Add this to your layout:

{% codeblock lang:ruby %}
<%= javascript_tag "var AUTH_TOKEN = #{form_authenticity_token.inspect};" if protect_against_forgery? %>
{% endcodeblock %}

Then, throw the following on your public/javascripts/application.js file - I haven't seen any downside to this, but leave a comment if you do.

{% codeblock lang:javascript %}
//public/javascripts/application.js

// This sets up the proper header for rails to understand the request type,
// and therefore properly respond to js requests (via respond_to block, for example)
$.ajaxSetup({ 
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
})

$(document).ready(function() {

  // UJS authenticity token fix: add the authenticy_token parameter
  // expected by any Rails POST request.
  $(document).ajaxSend(function(event, request, settings) {
    // do nothing if this is a GET request. Rails doesn't need
    // the authenticity token, and IE converts the request method
    // to POST, just because - with love from redmond.
    if (settings.type == 'GET') return;
    if (typeof(AUTH_TOKEN) == "undefined") return;
    settings.data = settings.data || "";
    settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
  });

});
{% endcodeblock %}

Having done that, let's prep our models. Let's assume you've created the <code>UserStory</code> and <code>Task</code> classes with the required <code>has_many</code> and <code>belongs_to</code> associations.

#### Models set up.

The models require just a few things: the acts_as_list plugin and a position attribute on the tasks table

* Install the [acts_as_list](http://github.com/rails/acts_as_list/tree/master) plugin:

{% codeblock lang:bash %}
$ script/plugin install git://github.com/rails/acts_as_list.git 
Initialized empty Git repository in /Users/hgimenez/code/foo/vendor/plugins/acts_as_list/.git/
remote: Counting objects: 13, done.
remote: Compressing objects: 100% (9/9), done.
remote: Total 13 (delta 2), reused 0 (delta 0)
Unpacking objects: 100% (13/13), done.
From git://github.com/rails/acts_as_list
 * branch            HEAD       -> FETCH_HEAD
$
{% endcodeblock %}

* Create a position column on the tasks table with:

{% codeblock lang:bash %}
script/generate migration add_position_to_tasks 
rake db:migrate
{% endcodeblock %}

* Add <code>acts_as_list :scope => :user_story</code> to the Task model.
* Optionally, add <code>default_scope => 'position'</code> to the Task model.

#### View setup

The idea is to create an <code><ul></code> of tasks that belong to a given user story. Each <code><li></code> contains a task and we have to "stage" the element's IDs so that when we serialize the list using JQuery, the task's IDs are sent over to the server via an AJAX request.

We also create a span with a class of "handle", which is where the user can hold on to when dragging and dropping tasks around.

{% codeblock lang:html %}
<ul id="tasks-list">
  <% @user_story.tasks.each do |t| %>
    <li id="task_<%= t.id -%>">
      <span class="name">
        <%= t.name -%>
      </span>
      <span class="handle">[handle]<span>
    </li>
  <% end %>
<ul>
{% endcodeblock %}

#### (Unobstrusive) javascript setup

Now we are ready to wire in the javascript on your view. At the bottom of your view, and using the <code>:javascript</code> content block created earlier, use [JQuery's sortable()](http://docs.jquery.com/UI/Sortable) function and attach it to the #tasks-list element:

{% codeblock lang:ruby %}
<% content_for :javascript do %>

  <% javascript_tag do %>
     $('#tasks-list').sortable(
        {
          axis: 'y', 
          dropOnEmpty:false, 
          handle: '.handle', 
          cursor: 'crosshair',
          items: 'li',
          opacity: 0.4,
          scroll: true,
          update: function(){
            $.ajax({
                type: 'post', 
                data: $('#tasks-list').sortable('serialize') + '&id=<%=@user_story.id-%>', 
                dataType: 'script', 
                complete: function(request){
                    $('#tasks-list').effect('highlight');
                  },
                url: '/user_stories/prioritize_tasks'})
            }
          })
    <% end %>
  
<% end %>
{% endcodeblock %}

This is basically saying: Take the element with an ID of <code>#tasks-list</code> and make it sortable. Do an <code>HTTP POST</code> to the <code>user_stories/prioritize_tasks</code> path with the serialized tasks-lists as data. Note that we're also appending the user_story id as a post parameter so that our controller action knows which tasks to prioritize.

Feel free to go over the [sortable()](http://docs.jquery.com/UI/Sortable) documentation to tweak the options.

#### Controller set up

The controller's work is to take the parameters sent in from the view and to set the position attribute of each of the user story's tasks. The parameters received in the controller look something like:

{% codeblock lang:ruby %}
params.inspect
 => {"authenticity_token"=>"9HJQs99d4vqhLwjPAdC8uSLwjPAd4OpbaJQs99dFCch8XisI=", "id"=>"1", "task"=>["2", "1"]}
{% endcodeblock %}

As expected, we receive the Rails authenticity token, as well as the id (the UserStory ID) and an array of task IDs (<code>params['task']</code> contains task IDs in the order specified by the user). 

Here's the implementation of the prioritize_tasks action:

{% codeblock lang:ruby %}
def prioritize_tasks
  user_story = UserStory.find(params[:id])
  tasks = user_story.tasks
  tasks.each do |task|
    task.position = params['task'].index(task.id.to_s) + 1
    task.save
  end
  render :nothing => true
end
{% endcodeblock %}

#### Route setup

Almost there. The one thing that's missing would be adding a collection route to the user_story resource for the prioritize_tasks action:

{% codeblock lang:ruby %}
  # add the :collection option
  map.resources :user_story, :collection => { :prioritize_tasks => :post }
{% endcodeblock %}

This pretty much wraps it up! This process will become easier as Rails core evolves and the Javascript framework becomes easier to swap out. It is known that Rails 3's helpers will not produce inline javascript. Instead, they will add hooks to your DOM elements in the form of HTML5's custom data attributes which then can be used by unobstrusive javascript code to add the appropriate behavior to the DOM elements. Even though Rails will continue to ship with the Prototype/Scriptaculous frameworks by default, JQuery will be easier to plug in, and the Rails helpers that simply add data attributes to your DOM elements can be used to achieve all sorts of presentation behavior.

Regardless of that, the closer you are to your Javascript, the better you'll understand how the pieces play together and the more control you'll have over the app's client side behavior.

##### Resources

* [Unobstrusive Javascript presentation](http://www.railsenvy.com/2008/1/3/unobtrusive-javascript) by Jason Seifer.
* [JQuery Railscast](http://railscasts.com/episodes/136-jquery)
* [HTML 5 data attributes](http://ejohn.org/blog/html-5-data-attributes/), an explanation by John Resig.
