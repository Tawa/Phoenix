{
  "families" : [
    {
      "components" : [
        {
          "dependencies" : [

          ],
          "modules" : [
            {
              "mock" : {

              }
            },
            {
              "implementation" : {

              }
            }
          ],
          "name" : {
            "family" : "Entity",
            "given" : "Package"
          }
        }
      ],
      "family" : {
        "ignoreSuffix" : true,
        "name" : "Entity"
      }
    },
    {
      "components" : [
        {
          "dependencies" : [

          ],
          "modules" : [
            {
              "mock" : {

              }
            },
            {
              "implementation" : {

              }
            },
            {
              "contract" : {

              }
            }
          ],
          "name" : {
            "family" : "Family",
            "given" : "Example"
          }
        }
      ],
      "family" : {
        "ignoreSuffix" : false,
        "name" : "Family"
      }
    },
    {
      "components" : [
        {
          "dependencies" : [
            {
              "name" : {
                "family" : "Family",
                "given" : "Example"
              }
            },
            {
              "name" : {
                "family" : "Entity",
                "given" : "Package"
              }
            }
          ],
          "modules" : [
            {
              "contract" : {

              }
            },
            {
              "mock" : {

              }
            },
            {
              "implementation" : {

              }
            }
          ],
          "name" : {
            "family" : "Shared",
            "given" : "Networking"
          }
        }
      ],
      "family" : {
        "folder" : "Shared",
        "ignoreSuffix" : true,
        "name" : "Shared"
      }
    }
  ],
  "selectedName" : {
    "family" : "Family",
    "given" : "Example"
  }
}