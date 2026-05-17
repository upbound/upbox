import models.io.upbound.aws.v1beta1 as awsv1beta1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1


_items = [
    metav1alpha1.E2ETest{
        metadata.name: ""
        spec= {
            crossplane.autoUpgrade.channel: "Rapid"
            defaultConditions: ["Ready"]
            manifests: [
                {
                    apiVersion = "aws.platform.upbound.io/v1alpha1"
                    kind = "UpboxSet"
                    metadata = {
                        name = "example"
                    }
                    spec = {
                        parameters = {
                            company = "upbound"
                            owner = "team-solutions"
                            networkId = "upbox-aws-network"
                            size = "micro"
                            amiId = "ami-06bc36b2df9129f2e"
                            users = {
                                yury = {
                                    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMXbvrMf29K2T/ubkmMlA4ER5NxJ+GlTqAkjF5rX/Mv yury@upbound.io"
                                }
                                tobias = {
                                    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKoZQbAbTmEQmFzsRwY1Qc9WEY3EPuryShqu1whWYCDt tobias.kasser@upbound.io"
                                }
                            }
                        }
                    }
                }
            ]
            extraResources: [
                {
                    apiVersion = "pkg.crossplane.io/v1"
                    kind = "Configuration"
                    metadata = {
                        name = "configuration-aws-network"
                    }
                    spec = {
                        package = "xpkg.upbound.io/upbound/configuration-aws-network:v0.24.0"
                    }
                }
                {
                    apiVersion = "aws.platform.upbound.io/v1alpha1"
                    kind = "XNetwork"
                    metadata = {
                        name = "upbox-aws-network"
                    }
                    spec = {
                        parameters = {
                            id = "upbox-aws-network"
                            region = "eu-west-1"
                            vpcCidrBlock = "192.168.0.0/16"
                            subnets = [
                                {
                                    availabilityZone = "eu-west-1a"
                                    $type = "public"
                                    cidrBlock = "192.168.0.0/18"
                                }
                                {
                                    availabilityZone = "eu-west-1b"
                                    $type = "public"
                                    cidrBlock = "192.168.64.0/18"
                                }
                                {
                                    availabilityZone = "eu-west-1a"
                                    $type = "private"
                                    cidrBlock = "192.168.128.0/18"
                                }
                                {
                                    availabilityZone = "eu-west-1b"
                                    $type = "private"
                                    cidrBlock = "192.168.192.0/18"
                                }
                            ]
                        }
                    }
                }
                awsv1beta1.ProviderConfig{
                    metadata = {
                        name = "default"
                    }
                    spec = {
                        credentials = {
                            source = "Upbound"
                            upbound = {
                                webIdentity = {
                                    roleARN = "arn:aws:iam::609897127049:role/solutions-e2e-provider-aws"
                                }
                            }
                        }
                    }
                }
            ]
            skipDelete: False
            timeoutSeconds: 4500
        }
    }
]
items= _items
