require "application_system_test_case"

class BedOrdersTest < ApplicationSystemTestCase
  setup do
    @bed_order = bed_orders(:one)
  end

  test "visiting the index" do
    visit bed_orders_url
    assert_selector "h1", text: "Bed Orders"
  end

  test "creating a Bed order" do
    visit bed_orders_url
    click_on "New Bed Order"

    fill_in "Audited by", with: @bed_order.audited_by_id
    fill_in "Created by", with: @bed_order.created_by_id
    fill_in "Date received", with: @bed_order.date_received
    fill_in "Deleted at", with: @bed_order.deleted_at
    fill_in "Patient", with: @bed_order.patient_id
    fill_in "Received by", with: @bed_order.received_by_id
    fill_in "Remit code", with: @bed_order.remit_code
    fill_in "Sent date", with: @bed_order.sent_date
    fill_in "Sent dy", with: @bed_order.sent_dy
    fill_in "Sent request by id", with: @bed_order.sent_request_by_id_id
    fill_in "Status", with: @bed_order.status
    click_on "Create Bed order"

    assert_text "Bed order was successfully created"
    click_on "Back"
  end

  test "updating a Bed order" do
    visit bed_orders_url
    click_on "Edit", match: :first

    fill_in "Audited by", with: @bed_order.audited_by_id
    fill_in "Created by", with: @bed_order.created_by_id
    fill_in "Date received", with: @bed_order.date_received
    fill_in "Deleted at", with: @bed_order.deleted_at
    fill_in "Patient", with: @bed_order.patient_id
    fill_in "Received by", with: @bed_order.received_by_id
    fill_in "Remit code", with: @bed_order.remit_code
    fill_in "Sent date", with: @bed_order.sent_date
    fill_in "Sent dy", with: @bed_order.sent_dy
    fill_in "Sent request by id", with: @bed_order.sent_request_by_id_id
    fill_in "Status", with: @bed_order.status
    click_on "Update Bed order"

    assert_text "Bed order was successfully updated"
    click_on "Back"
  end

  test "destroying a Bed order" do
    visit bed_orders_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Bed order was successfully destroyed"
  end
end
