# Rails Forms Overview

Imagine that you're on a roadtrip across the country (I'm already jealous), your starting point is Santa Barbara and your final destination is New York, NY. If you enter the addresses into Google Maps you'll be shown multiple routes, and each route has an associated duration.

How do you select which route to take? Some of the points that should be included in your decision are below:

* Duration

* Cities that you go through

* Landmarks that you want to drive through

Forms in Rails are similar to your roadtrip. Rails supplies a few different options to choose from when creating forms. How do you know the right option to select? Just like your roadtrip you consider the strengths of each form option and see how well it aligns with your intended behavior and the application requirements.

In this lesson we will review:

* Both of the main form implementations in Rails

* Discuss when one type of form should be selected over the other

* Walk through the different form options


## Form_tag

Attributes of the `form_tag` helper:

- Most basic form helper that's available in Rails

- Uses tag form elements to build out a form

- Unlike the `form_for` helper, it does not use a form builder

Let's build out a form that lets users enter in their cat's name and their associated color:

```erb
<%= form_tag("/cats") do %>
  <%= label_tag('cat[name]', "Name") %>
  <%= text_field_tag('cat[name]') %>

  <%= label_tag('cat[color]', "Color") %>
  <%= text_field_tag('cat[color]') %>

  <%= submit_tag "Create Cat" %>
<% end %>
```

This will build a form and auto generate the following HTML:

```html
<form accept-charset="UTF-8" action="/cats" method="POST">
  <label for="cat_name">Name</label>
  <input id="cat_name" name="cat[name]" type="text">
  <label for="cat_color">Color</label>
  <input id="cat_color" name="cat[color]" type="text">
  <input name="commit" type="submit" value="Create Cat">
</form>
```

## Form_for

Attributes for the `form_for` form helper method:

- More magical form helper in rails

- `form_for` is a ruby method into which a ruby object is passed, this means that a form that utilizes `form_for` is directly connected with an `ActiveRecord` model

- `form_for` yields a form builder object that lets you create form elements that correspond to attributes in the model

So what does this all mean? When you're using the `form_for` method, the object is passed as a `form_for` parameter, it creates corresponding inputs with each of the attributes. For example, if you have `form_for(@cat)`, the form field params would look like `cat[name]`, `cat[color]`, etc

Let's refactor our cat form that we discussed in the previous section, with `form_for` it can be simplified to look like this:

```erb
<%= form_for(@cat) do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name %>
  <%= f.label :color %>
  <%= f.text_field :color %>
  <%= f.submit %>
<% end %>
```

The `form_for` above will auto generate the following HTML:

```html
<form accept-charset="UTF-8" action="/cats" method="post">
  <label for="cat_name">Name</label>
  <input id="cat_name" name="cat[name]" type="text" />
  <label for="cat_color">Color</label>
  <input id="cat_color" name="cat[color]" type="text" />
  <input name="commit" type="submit" value="Create" />
</form>
```


## Differences between `form_for` and `form_tag`

Getting back to our roadtrip example, in order to make an informed decision on what route to take we need to know everything possible about both options. In like manner, in order to make a good choice for which form element to use, it's vital to understand what the differences are for each of them, the differences are subtle but extremely important to understand:

* `form_for` is essentially an advanced form helper that will yield an object (form builder) that you use to generate your form elements (text field, labels, submit button, etc)

* `form_tag` is a lower-level form helper that simply generates a `form` element. To simply add fields to the `form_tag` block, you add form element tags, such as `text_field_tag`, `number_field_tag`, `submit_tag`, etc

* `form_tag` makes no assumptions about what you're trying to do, and you're responsible for specifying exactly what the form is supposed to do (sending a `post` request, `patch` request, etc)

* `form_for` handles the retrieval of values from your object model, and will also try to route the form to the appropriate action specified in the controller.

So when would you choose one over the other? Below are some real world examples:

* `form_for` - this works well for forms that manage CRUD. Imagine that you have a blog posting application, a great fit for the `form_for` method would be the `Post` model. The reason is because the `Post` model would have the standard `ActiveRecord` setup, and therefore it's smart to take advantage of the functionality built into `form_for`.

* `form_tag` - this works well for forms that are not directly connected with models. For example, let's say that our blog posting application has a search engine, the search form would be a great fit for using `form_tag`.


## Fields_for

Attributes for `fields_for`:

- `fields_for` is a method that can be called on a form builder element

- `fields_for` allows you to render form fields for an object that's associated with the original form object

- form helper calls the assocation organizations, and provides fields for that association

Let's look at the below example of how you can integrate the `fields_for` helper:

```erb
<%= form_for(@cat) do |f| %>
  <%= f.text_field :name %>
  <%= f.fields_for(:organizations, Organization.new) do |org_field| %>
    <% org_field.text_field :name %>
  <% end %>
  <%= f.submit %>
<% end %>
```

Assuming that you have the `accepts_nested_attributes_for :organization` method set up in your `Cat` model and your params in your controller set up so that it accepts `organizations_attributes`, this form will also create an organization that's associated with the cat.

For example, if I created a cat named `Gerald`, and I provided the name `Catnappers` to the name attribute of the organization field, when I click `Create`, it will create a `Cat` object with the name `Gerald`, and is associated with an Organization object named `Catnappers`.

We won't go into detail on the nested form setup, this is more complex behavior that resides in the model, but it's good to know how this can be integrated into a form.


## Other Form Elements

### `collection_check_boxes`

- `collection_check_boxes` assumes that there is a `many-to-many` relationship in place. Let's imagine that you have a book publishing application: `books` have many `authors`, `authors` have many `books`

- `collection_check_boxes` typically are used with a form builder element in a `form_for`

Below is an example on how you can implement `collection_check_boxes`:

```erb
<%= form_for(@book) do |f| %>
  <%= f.label :title %>
  <%= f.text_field :title %>

  <%= f.collection_check_boxes :author_ids, Author.all, :id, :name %>

  <%= f.submit %>
<% end %>
```

- This form has a `collection_check_boxes` field, and there are several parameters passed in:
  - The first parameter of the method is `:author_ids`: this is a collection of all of the `:author_id`s that will be passed in if the corresponding checkbox is checked
  - The second parameter is `Author.all`: this is collection of all of the possible check box options that will be available in the form
  - The third parameter is `:id`: this is the parameter of an author that will be passed into the `:author_ids` collection once a checkbox is checked
  - The final parameter is `:name`: this is the attribute of author that will be rendered on the page next to the checkbox

### `collection_select`

- `collection_select` assumes that there is a one-to-many relationship in place. Imagine that you are creating a competitor for IMDB.com, you would have the model of a `movie` that has one `director`, and the `director` model would be setup to have many movies

Below is a sample implementation on how `collection_select` can be used in an application:

```erb
<%= form_for(@movie) do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name %>

  <%= f.collection_select :director_id, Director.all, :id, :name %>

  <%= f.submit %>
<% end %>
```

- This form has a `collection_select` field, and there are several parameters being passed in:
  - The first is the `:director_id`: this is the association of the movie object that you will be making once the form is submitted
  - The second is `Director.all`: this will provide a collection of all of the directors in the Directors table in the database for the drop-down element in the `collection_select` field
  - The third is `:id`: this is what `:director_id` will be set to once a director is selected from the list, and once the submit button is clicked, it will save that association to the directors-movies joins table
  - The final parameter is `:name`: this is the attribute that's shown in the dropdown list of directors (it would be confusing if only the ids of the directors were shown in the list, so we're specifying that it should specifically show the director's name here)

## Resources in routes.rb

- Probably the biggest difference between Sinatra and Rails

- In Sinatra, in `app.rb` you had blocks that corresponded to each path (fuses the router and the controller together)

- In Rails, you have this convention that separates the routes from the controllers

- Via the `resources` parameter, Rails metaprograms several routes for you that correspond to specific actions (`get`, `post`, `patch`)