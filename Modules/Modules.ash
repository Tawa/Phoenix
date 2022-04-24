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
              "contract" : {

              }
            },
            {
              "implementation" : {

              }
            },
            {
              "mock" : {

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
        "ignoreSuffix" : true,
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
              "implementation" : {

              }
            },
            {
              "mock" : {

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
        "ignoreSuffix" : false,
        "name" : "Shared"
      }
    }
  ],
  "selectedName" : {
    "family" : "Shared",
    "given" : "Networking"
  }
}