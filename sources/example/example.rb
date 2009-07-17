class Example < ActiveRecord::Base

  # Expect to be passed in a column of data (an array called fields) and sort it
  # Return a properly sorted array of fields
  def self.sort(fields)
    fields.sort # maybe it's that simple!
  end
  
  # Populate the column data for this field
  def self.field_for(legislators, column)
    
    # Return a hash indexed by a legislator's bioguide_id
    field = {}
    
    legislators.each do |legislator|
      field[legislator.bioguide_id] = case column
      when 'name'
        # For each legislator, you can return a scalar value for the column...
        'John Adams'
      when 'full name'
        # ...or you can use a hash to return one value for the API, and one for the frontend...
        {
          :html => 'John <strong>Quincy</strong> Adams',
          :data => 'John Quincy Adams'
        }
      when 'skill'
        # ...and you can use a hash to return hidden text that will be searchable by the filter.
        # The frontend will use the :data parameter if no :html parameter is given.
        {
          :data => 'BB',
          :searchable => 'Black Belt'
        }
      end
    end

    # You can give the column as a whole a few special optional attributes...
    
    # The text in the <th> field for that column (defaults to a titleizeation of the column name)
    field[:header] = "COLUMN HEADER"
    # The tooltip text for the <th> field (defaults to a titleizeation of the column name)
    field[:title] = "MOUSEOVER TEXT"
    field[:type] = "string" # or digit or currency, to force a certain kind of sorting
    field
  end
  
  
  # Called from rake sources:update
  #
  # Usual algorithm:
  #
  #     1. Grab the data if it's a dataset, put it into data/sourcename
  #     2. Parse the data (whether as files in data/sourcename or from an API)
  #     3. Store it into the local database
  #
  # Make sure to create an entry in sources.yml for the data source
  
  def self.update(options = {})
    # Return a 2-item array, with SUCCESS or FAILURE, followed by the status message
    ['SUCCESS', "Message on success"]
  end

end