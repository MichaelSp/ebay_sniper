class AuctionBidder
  @queue = :auction_bidder
  
  def self.perform(auction_id)
    
    $redis.setex("ebaysniper:auction:#{auction_id}", 6.minutes.to_i, "#{Socket.gethostname}:#{Process.pid}")
    auction = Auction.find(auction_id)
    ebay = EbayAction.new(auction.user)
    
    if auction.auction_status != "Deleted"
      # Update auction info
      auction.item = ebay.get_item(auction.item_id, nil)
      
      # See how long it takes to place a bid by testing with the smallest possible bid
      #time_start = Time.now
      #ebay.place_bid(auction.item_id, auction.item[:get_item_response][:item][:selling_status][:converted_current_price].to_f +
      #               auction.item[:get_item_response][:item][:selling_status][:bid_increment].to_f)
      #time_end = Time.now
      #time_diff = time_end - time_start
      
      # Sleeps for the time remaining in the auction, and subtracts 4 more seconds just for good measure.
      sleep_time = Time.parse(auction.item[:get_item_response][:item][:listing_details][:end_time]).localtime - Time.now - 4 - auction.lead_time
      unless sleep_time < 0
        sleep(sleep_time)
      end
      
      # Does another check to make sure the user hasn't deleted the auction in the time the job was sleeping
      if auction.auction_status != "Deleted"
        # Places the bid
        ebay.place_bid(auction.item_id, auction.max_bid)
      end
    end
  end
end