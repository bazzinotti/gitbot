require 'net/http'

params = {
	"comment_ID"=>"7", "comment_post_ID"=>"6", "comment_author"=>"bazz1", 
	"comment_author_email"=>"mbazzinotti@gmail.com", 
	"comment_author_url"=>"http://bazz1.wordpress.com", 
	"comment_author_IP"=>"73.167.164.110", 
	"comment_date"=>"2016-05-15 05:23:09", 
	"comment_date_gmt"=>"2016-05-15 05:23:09", 
	"comment_content"=>"test", "comment_karma"=>"0", "comment_approved"=>"1", 
	"comment_agent"=>"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36",
	"comment_type"=>"", "comment_parent"=>"0", "user_id"=>"14669659", "approval"=>"1",
	"hook"=>"comment_post"
}
uri = URI('http://localhost:5651/wordpress')
# res = Net::HTTP.post_form(uri, params)
# puts res.body

req = Net::HTTP::Post.new(uri)
req['Referer'] = "https://snesflasher.wordpress.com"
req.form_data = params

res = Net::HTTP.start(uri.hostname, uri.port) {|http|
  http.request(req)
}
