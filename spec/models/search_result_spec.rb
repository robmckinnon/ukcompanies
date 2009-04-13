require File.dirname(__FILE__) + '/../spec_helper'

describe SearchResult do

  assert_model_has_one :search
  assert_model_has_one :company

end
