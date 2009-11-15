require File.dirname(__FILE__) + '/../spec_helper'

describe SearchResult do

  assert_model_belongs_to :search
  assert_model_belongs_to :company

end
