
## Form_tag
- Most basic form helper that's available in Rails
- Uses tag form elements to build out a form
- Unlike the `form_for` helper, it does not use a form builder

```erb
<%= form_tag("/cats") do %>
  <%= label_tag('cat[name]', "Name") %>
  <%= text_field_tag('cat[name]') %>

  <%= label_tag('cat[color]', "Color") %>
  <%= text_field_tag('cat[color]') %>

  <%= submit_tag "Create Cat" %>
<% end %>
```

This will build a form that looks like this:

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
- More magical form helper in rails
- form_for is a ruby method into which a ruby object is passed
- form_for yields a form builder object (typically `f`)
- methods to create form controls are called on `f`, the form builder element
- when the object is passed as a form_for parameter, it creates corresponding inputs with each of the attributes
    - if i had `form_for(@cat)`, then the form field params would look like `cat[name]`, `cat[color]`, etc
- in keeping with Rails convention regarding RESTful routes, there should be a resource declared for each model object (eg, `resources :cats`)

```erb
<%= form_for(@cat) do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name %>
  <%= f.label :color %>
  <%= f.text_field :color %>
  <%= f.submit %>
<% end %>
```

The `form_for` above will render the following HTML:

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
- The differences are subtle but extremely important to understand
- `form_for` is essentially an advanced form helper that will yield an object (form builder) that you use to generate your form elements (text field, labels, submit button, etc)
- `form_tag` is a lower-level form helper that simply generates a `form` element. To simply add fields to the `form_tag` block, you add form element tags, such as `text_field_tag`, `number_field_tag`, `submit_tag`, etc
- `form_tag` makes no assumptions about what you're trying to do, and you're responsible for specifying exactly what the form is supposed to do (sending a `post` request, `patch` request, etc)
- `form_for` handles the retrieval of values from your object model, and will also try to route the form to the appropriate action specified in the controller.

## Fields_for
- `fields_for` is a method that can be called on a form builder element
- `fields_for` allows you to render form fields for an object that's' associated with the original form object
- form helper calls the assocation organizations, and provides fields for that association

```erb
<%= form_for(@cat) do |f| %>
  <%= f.text_field :name %>
  <%= f.fields_for(:organizations, Organization.new) do |org_field| %>
    <% org_field.text_field :name %>
  <% end %>
  <%= f.submit %>
<% end %>
```

- Assuming that you have the `accepts_nested_attributes_for :organization` method set up in your `Cat` model and your params in your controller set up so that it accepts `organizations_attributes`, this form will also create an organization that's associated with the cat.
- For example, if I created a cat named Gerald, and I provided the name Catnappers to the name attribute of the organization field, when I click `Create`, it will create a Cat object with the name Gerald, and is associated with an Organization object named Catnappers.

### accepts_nested_attributes_for  
- this goes into the model
- Allows you to implicitly create nested attributes for object associations
- closely tied in with the `fields_for` concept

## Other Form Elements

### collection_check_boxes
- It assumes that there is a many-to-many relationship in place (books have many authors, authors have many books)
- Typically used with a form builder element in a `form_for`

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

### collection_select
- In this case, this form assumes that there is a one-to-many relationship in place (movie has one director, director has many movies)
- Used in this case with a form builder element in a `form_for` helper

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

## Resources in `routes.rb`
- probably the biggest difference between Sinatra and Rails
- In Sinatra, in `app.rb` you had blocks that corresponded to each path (fuses the router and the controller together)
- In Rails, you have this convention that separates the routes from the controllers
- Via the `resources` parameter, Rails metaprograms several routes for you that correspond to specific actions (`get`, `post`, `patch`)
