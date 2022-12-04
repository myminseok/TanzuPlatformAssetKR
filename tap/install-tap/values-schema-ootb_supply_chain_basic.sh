#   ootb-delivery-basic.tanzu.vmware.com                 Tanzu App Platform Out of The Box Delivery Basic                          Out of The Box Delivery Basic.                                                                                                                                 0.10.2
#   ootb-supply-chain-basic.tanzu.vmware.com             Tanzu App Platform Out of The Box Supply Chain Basic                      Out of The Box Supply Chain Basic.                                                                                                                             0.10.2
#   ootb-supply-chain-testing-scanning.tanzu.vmware.com  Tanzu App Platform Out of The Box Supply Chain with Testing and Scanning  Out of The Box Supply Chain with Testing and Scanning.                                                                                                         0.10.2
#   ootb-supply-chain-testing.tanzu.vmware.com           Tanzu App Platform Out of The Box Supply Chain with Testing               Out of The Box Supply Chain with Testing.                                                                                                                      0.10.2
#   ootb-templates.tanzu.vmware.com                      Tanzu App Platform Out of The Box Templates                               Out of The Box Templates.                                                                                                                                      0.10.2


tanzu package available get ootb-supply-chain-basic.tanzu.vmware.com/0.10.2 --values-schema --namespace tap-install
tanzu package available get ootb-supply-chain-testing-scanning.tanzu.vmware.com/0.10.2 --values-schema --namespace tap-install
