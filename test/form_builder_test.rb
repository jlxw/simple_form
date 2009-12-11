require 'test_helper'

class FormBuilderTest < ActionView::TestCase

  def with_form_for(object, attribute, options={})
    simple_form_for object do |f|
      concat f.input attribute, options
    end
  end

  def with_button_for(object, *args)
    simple_form_for object do |f|
      concat f.button *args
    end
  end

  def with_error_for(object, *args)
    simple_form_for object do |f|
      concat f.error *args
    end
  end

  def with_hint_for(object, *args)
    simple_form_for object do |f|
      concat f.hint *args
    end
  end

  def with_label_for(object, *args)
    simple_form_for object do |f|
      concat f.label *args
    end
  end

  def with_association_for(object, *args)
    simple_form_for object do |f|
      concat f.association *args
    end
  end

  test 'builder should generate text fields for string columns' do
    with_form_for @user, :name
    assert_select 'form input#user_name.string'
  end

  test 'builder should generate text areas for text columns' do
    with_form_for @user, :description
    assert_select 'form textarea#user_description.text'
  end

  test 'builder should generate a checkbox for boolean columns' do
    with_form_for @user, :active
    assert_select 'form input[type=checkbox]#user_active.boolean'
  end

  test 'builder should use integer text field for integer columns' do
    with_form_for @user, :age
    assert_select 'form input#user_age.integer'
  end

  test 'builder should generate decimal text field for decimal columns' do
    with_form_for @user, :credit_limit
    assert_select 'form input#user_credit_limit.decimal'
  end

  test 'builder should generate password fields for columns that match password' do
    with_form_for @user, :password
    assert_select 'form input#user_password.password'
  end

  test 'builder should generate date select for date columns' do
    with_form_for @user, :born_at
    assert_select 'form select#user_born_at_1i.date'
  end

  test 'builder should generate time select for time columns' do
    with_form_for @user, :delivery_time
    assert_select 'form select#user_delivery_time_4i.time'
  end

  test 'builder should generate datetime select for datetime columns' do
    with_form_for @user, :created_at
    assert_select 'form select#user_created_at_1i.datetime'
  end

  test 'builder should generate datetime select for timestamp columns' do
    with_form_for @user, :updated_at
    assert_select 'form select#user_updated_at_1i.datetime'
  end

  test 'build should generate select if a collection is given' do
    with_form_for @user, :age, :collection => 1..60
    assert_select 'form select#user_age.select'
  end

  test 'builder should allow overriding default input type for text' do
    with_form_for @user, :name, :as => :text
    assert_no_select 'form input#user_name'
    assert_select 'form textarea#user_name.text'

    with_form_for @user, :active, :as => :radio
    assert_no_select 'form input[type=checkbox]'
    assert_select 'form input.radio[type=radio]', :count => 2

    with_form_for @user, :born_at, :as => :string
    assert_no_select 'form select'
    assert_select 'form input#user_born_at.string'
  end

  test 'builder should allow passing options to input' do
    with_form_for @user, :name, :input_html => { :class => 'my_input', :id => 'my_input' }
    assert_select 'form input#my_input.my_input.string'
  end

  test 'builder should generate a input with label' do
    with_form_for @user, :name
    assert_select 'form label.string[for=user_name]'
  end

  test 'builder should be able to disable the label for a input' do
    with_form_for @user, :name, :label => false
    assert_no_select 'form label'
  end

  test 'builder should use custom label' do
    with_form_for @user, :name, :label => 'Yay!'
    assert_no_select 'form label', 'Yay!'
  end

  test 'builder should not generate hints for a input' do
    with_form_for @user, :name
    assert_no_select 'span.hint'
  end

  test 'builder should be able to add a hint for a input' do
    with_form_for @user, :name, :hint => 'test'
    assert_select 'span.hint', 'test'
  end

  test 'builder should be able to disable a hint even if it exists in i18n' do
    store_translations(:en, :simple_form => { :hints => { :name => 'Hint test' } }) do
      with_form_for @user, :name, :hint => false
      assert_no_select 'span.hint'
    end
  end

  test 'builder should generate errors for attribute without errors' do
    with_form_for @user, :credit_limit
    assert_no_select 'span.errors'
  end

  test 'builder should generate errors for attribute with errors' do
    with_form_for @user, :name
    assert_select 'span.error', "can't be blank"
  end

  test 'builder should be able to disable showing errors for a input' do
    with_form_for @user, :name, :error => false
    assert_no_select 'span.error'
  end

  test 'builder support wrapping around an specific tag' do
    swap SimpleForm, :wrapper_tag => :p do
      with_form_for @user, :name
      assert_select 'form p label[for=user_name]'
      assert_select 'form p input#user_name.string'
    end
  end

  test 'builder wrapping tag adds default css classes' do
    swap SimpleForm, :wrapper_tag => :p do
      with_form_for @user, :name
      assert_select 'form p.required.string'

      with_form_for @user, :age, :required => false
      assert_select 'form p.optional.integer'
    end
  end

  test 'builder wrapping tag allow custom options to be given' do
    swap SimpleForm, :wrapper_tag => :p do
      with_form_for @user, :name, :wrapper_html => { :id => "super_cool", :class => 'yay' }
      assert_select 'form p#super_cool.required.string.yay'
    end
  end

  test 'builder allows wrapper tag to be given on demand' do
    simple_form_for @user do |f|
      concat f.input :name, :wrapper => :b
    end
    assert_select 'form b.required.string'
  end

  test 'nested simple fields should yields an instance of FormBuilder' do
    simple_form_for :user do |f|
      f.simple_fields_for :posts do |posts_form|
        assert posts_form.instance_of?(SimpleForm::FormBuilder)
      end
    end
  end

  test 'builder should generate properly when object is not present' do
    with_form_for :project, :name
    assert_select 'form input.string#project_name'
  end

  test 'builder should generate password fields based on attribute name when object is not present' do
    with_form_for :project, :password_confirmation
    assert_select 'form input[type=password].password#project_password_confirmation'
  end

  test 'builder should generate text fields by default for all attributes when object is not present' do
    with_form_for :project, :created_at
    assert_select 'form input.string#project_created_at'
    with_form_for :project, :budget
    assert_select 'form input.string#project_budget'
  end

  test 'builder should allow overriding input type when object is not present' do
    with_form_for :project, :created_at, :as => :datetime
    assert_select 'form select.datetime#project_created_at_1i'
    with_form_for :project, :budget, :as => :decimal
    assert_select 'form input.decimal#project_budget'
  end

  # ERRORS
  test 'builder should generate an error component tag for the attribute' do
    with_error_for @user, :name
    assert_select 'span.error', "can't be blank"
  end

  test 'builder should allow passing options to error tag' do
    with_error_for @user, :name, :id => 'name_error'
    assert_select 'span.error#name_error', "can't be blank"
  end

  # HINTS
  test 'builder should generate a hint component tag for the attribute' do
    store_translations(:en, :simple_form => { :hints => { :user => { :name => "Add your name" }}}) do
      with_hint_for @user, :name
      assert_select 'span.hint', 'Add your name'
    end
  end

  test 'builder should generate a hint component tag for the given text' do
     with_hint_for @user, 'Hello World!'
     assert_select 'span.hint', 'Hello World!'
   end

  test 'builder should allow passing options to hint tag' do
    with_hint_for @user, :name, :hint => 'Hello World!', :id => 'name_hint'
    assert_select 'span.hint#name_hint', 'Hello World!'
  end

  # LABELS
  test 'builder should generate a label component tag for the attribute' do
    with_label_for @user, :name
    assert_select 'label.string[for=user_name]', /Name/
  end

  test 'builder should allow passing options to label tag' do
    with_label_for @user, :name, :label => 'My label', :id => 'name_label'
    assert_select 'label.string.required#name_label', /My label/
  end

  test 'builder should fallback to default label when string is given' do
    with_label_for @user, :name, 'Nome do usuário'
    assert_select 'label', 'Nome do usuário'
    assert_no_select 'label.string'
  end

  test 'builder allows label order to be changed' do
    swap SimpleForm, :label_text => lambda { |l, r| "#{l}:" } do
      with_label_for @user, :age
      assert_select 'label.integer[for=user_age]', "Age:"
    end
  end

  # BUTTONS
  test 'builder should create buttons' do
    with_button_for :post, :submit
    assert_select 'form input.submit[type=submit][value=Submit Post]'
  end

  test 'builder should create buttons for new records' do
    @user.new_record!
    with_button_for @user, :submit
    assert_select 'form input.create[type=submit][value=Create User]'
  end

  test 'builder should create buttons for existing records' do
    with_button_for @user, :submit
    assert_select 'form input.update[type=submit][value=Update User]'
  end

  test 'builder should create buttons using human_name' do
    @user.class.expects(:human_name).returns("Usuario")
    with_button_for @user, :submit
   assert_select 'form input[type=submit][value=Update Usuario]'
  end

  test 'builder should create object buttons with localized labels' do
    store_translations(:en, :simple_form => { :create => "Criar {{model}}", :update => "Atualizar {{model}}" }) do
      with_button_for @user, :submit
      assert_select 'form input[type=submit][value=Atualizar User]'

      @user.new_record!
      with_button_for @user, :submit
      assert_select 'form input[type=submit][value=Criar User]'
    end
  end

  test 'builder should create non object buttons with localized labels' do
    store_translations(:en, :simple_form => { :submit => "Enviar {{model}}" }) do
      with_button_for :post, :submit
      assert_select 'form input[type=submit][value=Enviar Post]'
    end
  end

  test 'builder forwards first options as button text' do
    with_button_for :post, :submit, "Send it!"
    assert_select 'form input[type=submit][value=Send it!]'
  end

  test 'builder forwards label option as button text' do
    with_button_for :post, :submit, :label => "Send it!"
    assert_select 'form input[type=submit][value=Send it!]'
  end

  test 'builder forwards all options except label to button' do
    with_button_for :post, :submit, :class => "cool", :id => "super"
    assert_select 'form input#super.submit.cool[type=submit]'
  end

  test 'builder calls any button tag' do
    with_button_for :post, :image_submit, "/image/foo/bar"
    assert_select 'form input[src=/image/foo/bar][type=image]'
  end

  # ASSOCIATIONS
  test 'builder should not allow creating an association input when no object exists' do
    assert_raise ArgumentError do
      with_association_for :post, :author
    end
  end

  test 'builder should allow creating an association input generating collection' do
    with_association_for @user, :company
    assert_select 'form select.select#user_company_id'
    assert_select 'form select option[value=1]', 'Company 1'
    assert_select 'form select option[value=2]', 'Company 2'
    assert_select 'form select option[value=3]', 'Company 3'
  end

  test 'builder should allow passing conditions to find collection' do
    with_association_for @user, :company, :conditions => { :id => 1 }
    assert_select 'form select.select#user_company_id'
    assert_select 'form select option[value=1]'
    assert_no_select 'form select option[value=2]'
    assert_no_select 'form select option[value=3]'
  end

  test 'builder should allow passing order to find collection' do
    with_association_for @user, :company, :order => 'name'
    assert_select 'form select.select#user_company_id'
    assert_no_select 'form select option[value=1]'
    assert_no_select 'form select option[value=2]'
    assert_select 'form select option[value=3]'
  end

  test 'builder should allow overriding condition to association input' do
    with_association_for @user, :company, :include_blank => false,
                         :collection => [Company.new(999, 'Teste')]
    assert_select 'form select.select#user_company_id'
    assert_no_select 'form select option[value=1]'
    assert_select 'form select option[value=999]', 'Teste'
    assert_select 'form select option', :count => 1
  end

  test 'builder with association input should allow using radios' do
    with_association_for @user, :company, :as => :radio
    assert_select 'form input.radio#user_company_id_1'
    assert_select 'form input.radio#user_company_id_2'
    assert_select 'form input.radio#user_company_id_3'
  end
end