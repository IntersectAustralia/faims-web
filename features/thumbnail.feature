Feature: Android
  Generate thumbnails for images and videos

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I have a project modules dir
    And I perform HTTP authentication

  Scenario Outline: I can generate thumbnails for image and video files
    Given I have project module "Thumbnail"
    And I upload <type> file "<file>" to Thumbnail succeeds
    Then I should have stored <type> file "<file>" for Thumbnail
    And I should have thumbnail for "<file>" with type "<type>" for Thumbnail
  Examples:
    | file                                                                        | type   |
    | files/536bd80c-e78e-4300-aa71-93d07eb71b6d_image-1410411623538.original.jpg | app    |
    | files/990810e7-9bfb-4211-b970-50c03d023648_image-1410411612633.original.jpg | app    |
    | files/cb57fdf7-ba49-4223-9a6c-8d8d0266f85b_video-1410411633095.original.mp4 | app    |
    | files/ec4898d9-aa8e-4671-a82f-875963783dcf_video-1410411653987.original.mp4 | app    |
    | files/536bd80c-e78e-4300-aa71-93d07eb71b6d_image-1410411623538.original.jpg | server |
    | files/990810e7-9bfb-4211-b970-50c03d023648_image-1410411612633.original.jpg | server |
    | files/cb57fdf7-ba49-4223-9a6c-8d8d0266f85b_video-1410411633095.original.mp4 | server |
    | files/ec4898d9-aa8e-4671-a82f-875963783dcf_video-1410411653987.original.mp4 | server |

  Scenario Outline: I cannot generate thumbnails for non image and video files
    Given I have project module "Thumbnail"
    And I upload <type> file "<file>" to Thumbnail succeeds
    Then I should have stored <type> file "<file>" for Thumbnail
    And I should not have thumbnail for "<file>" with type "<type>" for Thumbnail
  Examples:
    | file                                                              | type   |
    | files/3be5bff1-fa53-4e29-a797-ca0f3c3a5042_ui_schema.original.xml | app    |
    | files/ed4f0355-44c6-4ccd-bc7b-5daf0157699b_ui_logic.original.bsh  | app    |
    | files/3be5bff1-fa53-4e29-a797-ca0f3c3a5042_ui_schema.original.xml | server |
    | files/ed4f0355-44c6-4ccd-bc7b-5daf0157699b_ui_logic.original.bsh  | server |

  Scenario Outline: I do not generate thumbnails for images and videos if attributes don't use thumbnails
    Given I have project module "Thumbnail"
    And I upload <type> file "<file>" to Thumbnail succeeds
    Then I should have stored <type> file "<file>" for Thumbnail
    And I should not have thumbnail for "<file>" with type "<type>" for Thumbnail
  Examples:
    | file                                                               | type   |
    | files/536bd80c-e78e-4300-aa71-93d07eb71b6d_image-1410411623538.jpg | app    |
    | files/990810e7-9bfb-4211-b970-50c03d023648_image-1410411612633.jpg | app    |
    | files/cb57fdf7-ba49-4223-9a6c-8d8d0266f85b_video-1410411633095.mp4 | app    |
    | files/ec4898d9-aa8e-4671-a82f-875963783dcf_video-1410411653987.mp4 | app    |
    | files/536bd80c-e78e-4300-aa71-93d07eb71b6d_image-1410411623538.jpg | server |
    | files/990810e7-9bfb-4211-b970-50c03d023648_image-1410411612633.jpg | server |
    | files/cb57fdf7-ba49-4223-9a6c-8d8d0266f85b_video-1410411633095.mp4 | server |
    | files/ec4898d9-aa8e-4671-a82f-875963783dcf_video-1410411653987.mp4 | server |

  Scenario Outline: I can download thumbnail for images and videos
    Given I have project module "Thumbnail"
    And I upload <type> file "<file>" to Thumbnail succeeds
    Then I should have stored <type> file "<file>" for Thumbnail
    And I should have thumbnail for "<file>" with type "<type>" for Thumbnail
    And I requested the android <type> file download "<thumbnail>" link for Thumbnail
    Then I should download <type> "<thumbnail>" for "Thumbnail"
  Examples:
    | file                                                                        | type | thumbnail                                                                    |
    | files/536bd80c-e78e-4300-aa71-93d07eb71b6d_image-1410411623538.original.jpg | app  | files/536bd80c-e78e-4300-aa71-93d07eb71b6d_image-1410411623538.thumbnail.jpg |
    | files/cb57fdf7-ba49-4223-9a6c-8d8d0266f85b_video-1410411633095.original.mp4 | app  | files/cb57fdf7-ba49-4223-9a6c-8d8d0266f85b_video-1410411633095.thumbnail.jpg |

  Scenario Outline: I cannot download thumbnail for images and videos if thumbnail does not exist
    Given I have project module "Thumbnail"
    And I upload <type> file "<file>" to Thumbnail succeeds
    Then I should have stored <type> file "<file>" for Thumbnail
    And I should not have thumbnail for "<file>" with type "<type>" for Thumbnail
    And I requested the android <type> file download "<thumbnail>" link for Thumbnail
    Then I should see bad request page
  Examples:
    | file                                                              | type |
    | files/3be5bff1-fa53-4e29-a797-ca0f3c3a5042_ui_schema.original.xml | app  |
    | files/ed4f0355-44c6-4ccd-bc7b-5daf0157699b_ui_logic.original.bsh  | app  |
