module CompaniesHelper

 def logo_image(company)
   image_tag (company.logo_image_url ? company.logo_image_url : 'placeholder.gif'), :class => 'logo' 
 end
 
end

