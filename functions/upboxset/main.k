import models.io.upbound.platform.aws.v1alpha1 as platformawsv1alpha1

oxr = platformawsv1alpha1.UpboxSet{**option("params").oxr}

_metadata = lambda name: str -> any {
    { annotations = { "krm.kcl.dev/composition-resource-name" = name }}
}

_items = [
    platformawsv1alpha1.Upbox{
       metadata = {
           **_metadata("upbox-{}".format(user))
           name = "{}-{}-{}".format(oxr.spec.parameters.company, oxr.spec.parameters.owner, user)
           labels = {
               "upbox.aws.platform.upbound.io/owner" = oxr.spec.parameters.owner
               "upbox.aws.platform.upbound.io/company" = oxr.spec.parameters.company
           }
       }
       spec = {
           parameters = {
               company = oxr.spec.parameters.company
               owner = oxr.spec.parameters.owner  # Changed from networkId to owner
               size = oxr.spec.parameters.size
               amiId = oxr.spec.parameters.amiId
               zone = oxr.spec.parameters.zone
               networkId = oxr.spec.parameters.networkId
               publicKey = oxr.spec.parameters.users[user].publicKey
               providerConfigName = oxr.spec.parameters.providerConfigName
           }
       }
    } for user in oxr.spec.parameters.users
]

items = _items
