require 'net/http/post/multipart'

class PdfjsService
  def self.merge_xfdf(document)
    # conn = Faraday.new(url: ENV['PDFJS_EXPRESS_URL']) do |f|
    #   f.request :multipart
    #   f.adapter :net_http
    #   f.response :logger
    # end

    body = {}
    body[:license] = ENV['PDFJS_EXPRESS_LICENSE']

    body[:file] = "#{ENV['MERGE_DOMAIN']}/meetings/#{document.meeting.id}/documents/#{document.id}/merge"

    body[:xfdf] = document.xfdf
    # body[:xfdf] = '<?xml version="1.0" encoding="UTF-8" ?>
    # <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
    #   <fields>
    #     <field name="ACombo"><value>Red</value></field>
    #   </fields>
    #   <annots>
    #     <square subject="Rectangle" page="0" rect="306.01,744.85,408.98,775.94" flags="print" name="447c49b7-5e50-4b13-adc8-c291102466e6" title="Guest" color="#000000" width="5">
    #       <popup flags="print,nozoom,norotate" page="0" rect="0,767,112.5,842" open="no"/>
    #     </square>
    #   </annots>
    # </xfdf>'

    body[:headers] = []

    url = URI.parse(ENV['PDFJS_EXPRESS_URL'])
    req = Net::HTTP::Post::Multipart.new(url.path, body)
    res = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
      result = JSON.parse(http.request(req).body)
      download_merged_pdf(result['url'], result['key'], document)
    end
  end

  def self.download_merged_pdf(file_url, key, document)
    url = URI(file_url)
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Authorization"] =  key
    response = https.request(request)
    document.file.attach(io: StringIO.new(response.body) , filename: "#{document.id}.pdf")
    document.update_column(:xfdf_merged, true)
    # open(temp_url, "wb") do |file|
    #   file.write(response.body)
    # end
  end
end