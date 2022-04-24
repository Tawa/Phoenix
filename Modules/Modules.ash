{
  "families" : [
    {
      "components" : [
        {
          "dependencies" : [

          ],
          "modules" : [
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
            "family" : "ViewModel",
            "given" : "Home"
          }
        }
      ],
      "family" : {
        "ignoreSuffix" : false,
        "name" : "ViewModel"
      }
    }
  ],
  "selectedName" : {
    "family" : "ViewModel",
    "given" : "Home"
  }
}