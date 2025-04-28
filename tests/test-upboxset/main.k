import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.aws.ec2.v1beta1 as ec2v1beta1
import models.io.upbound.platform.aws.v1alpha1 as platformawsv1alpha1

_items = [
    metav1alpha1.CompositionTest{
        metadata.name: ""
        spec= {
            assertResources: [
                {
                    apiVersion = "aws.platform.upbound.io/v1alpha1"
                    kind = "UpboxSet"
                    metadata = {
                        name = "example"
                    }
                }
                platformawsv1alpha1.Upbox{
                    metadata = {
                        annotations = {
                            "crossplane.io/composition-resource-name" = "upbox-tobias"
                        }
                        generateName = "example-"
                        labels = {
                            "crossplane.io/composite" = "example"
                            "upbox.aws.platform.upbound.io/company" = "upbound"
                            "upbox.aws.platform.upbound.io/owner" = "team-solutions"
                        }
                        name = "upbound-team-solutions-tobias"
                    }
                    spec = {
                        parameters = {
                            amiId = "ami-0b3d63e88dd60b19c"
                            company = "upbound"
                            networkId = "upbox-aws-network"
                            owner = "team-solutions"
                            providerConfigName = "default"
                            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKoZQbAbTmEQmFzsRwY1Qc9WEY3EPuryShqu1whWYCDt tobias.kasser@upbound.io"
                            size = "micro"
                            zone = "a"
                        }
                    }
                }
                platformawsv1alpha1.Upbox{
                    metadata = {
                        annotations = {
                            "crossplane.io/composition-resource-name" = "upbox-yury"
                        }
                        generateName = "example-"
                        labels = {
                            "crossplane.io/composite" = "example"
                            "upbox.aws.platform.upbound.io/company" = "upbound"
                            "upbox.aws.platform.upbound.io/owner" = "team-solutions"
                        }
                        name = "upbound-team-solutions-yury"
                    }
                    spec = {
                        parameters = {
                            amiId = "ami-0b3d63e88dd60b19c"
                            company = "upbound"
                            networkId = "upbox-aws-network"
                            owner = "team-solutions"
                            providerConfigName = "default"
                            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMXbvrMf29K2T/ubkmMlA4ER5NxJ+GlTqAkjF5rX/Mv yury@upbound.io"
                            size = "micro"
                            zone = "a"
                        }
                    }
                }
            ]
            extraResources = [
                ec2v1beta1.VPC{
                    metadata = {
                        labels = {
                            "networks.aws.platform.upbound.io/network-id" = "upbox-aws-network"
                        }
                        name = "some-vpc"
                    }
                    spec = {
                        forProvider = {
                            region = "us-west-2"
                        }
                    }
                }
            ]
            compositionPath: "apis/upboxsets/composition.yaml"
            xrPath: "examples/upboxset/example.yaml"
            xrdPath: "apis/upboxsets/definition.yaml"
            timeoutSeconds: 60
            validate: False
        }
    }
]
items= _items
