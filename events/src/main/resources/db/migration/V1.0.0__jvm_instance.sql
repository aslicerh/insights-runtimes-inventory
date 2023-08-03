CREATE TABLE public.jvm_instance(
    id uuid NOT NULL,
    linking_hash character varying(255) NOT NULL,
    account_id character varying(50) NOT NULL,
    org_id character varying(50) NOT NULL,
    hostname character varying(50) NOT NULL,
    launch_time bigint NOT NULL,
    vendor character varying(255) NOT NULL,
    version_string character varying(255) NOT NULL,
    version character varying(255) NOT NULL,
    major_version integer NOT NULL,
    os_arch character varying(50) NOT NULL,
    processors integer NOT NULL,
    heap_max integer NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    details jsonb,
    PRIMARY KEY (id)
);

CREATE TABLE public.jar_hash(
    id uuid NOT NULL,
    instance_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    group_id character varying(255) NOT NULL,
    vendor character varying(255) NOT NULL,
    version character varying(255) NOT NULL,
    sha1checksum character varying(255) NOT NULL,
    sha256checksum character varying(255) NOT NULL,
    sha512checksum character varying(255) NOT NULL,
    PRIMARY KEY (id)
);

ALTER TABLE IF EXISTS jvm_instance
  ADD CONSTRAINT U_LINK_HASH
    UNIQUE (linking_hash);

ALTER TABLE IF EXISTS jar_hash
  ADD CONSTRAINT FK_JAR_HASH_LINK_JVM_INSTANCE
    FOREIGN KEY (instance_id) REFERENCES jvm_instance(id)

CREATE TABLE public.eap_instance(
    id uuid NOT NULL,
  private Set<JarHash> jars;
  @OneToMany(mappedBy = "eap_instance", cascade = CascadeType.ALL, orphanRemoval = true)
  private Set<JarHash> modules;
  @OneToOne(
      mappedBy = "eap_instance",
      cascade = CascadeType.ALL,
      orphanRemoval = true,
      fetch = FetchType.LAZY)
  private EapConfiguration configuration;

  @OneToMany(mappedBy = "eap_instance", cascade = CascadeType.ALL, orphanRemoval = true)
  private Set<EapDeployment> deployments;
    app_client_exception character varying(255) NOT NULL,
    app_name character varying(255) NOT NULL,
    app_transport_cert_https character varying(255) NOT NULL,
    app_transport_type_file character varying(255) NOT NULL,
    app_transport_type_https character varying(255) NOT NULL,
    app_user_dir character varying(255) NOT NULL,
    app_user_name character varying(255) NOT NULL,
    java_class_path character varying(255) NOT NULL,
    java_class_version character varying(255) NOT NULL,
    java_command character varying(255) NOT NULL,
    java_home character varying(255) NOT NULL,
    java_library_path character varying(255) NOT NULL,
    java_specification_vendor character varying(255) NOT NULL,
    java_vendor character varying(255) NOT NULL,
    java_vendor_version character varying(255) NOT NULL,
    java_vm_name character varying(255) NOT NULL,
    java_vm_vendor character varying(255) NOT NULL,
    jvm_heap_gc_details character varying(255) NOT NULL,
    jvm_heap_min character varying(255) NOT NULL,
    jvm_pid character varying(255) NOT NULL,
    jvm_report_time character varying(255) NOT NULL,
    system_hostname character varying(255) NOT NULL,
    system_os_name character varying(255) NOT NULL,
    eap_version character varying(255) NOT NULL,
    eap_xp boolean NOT NULL,
    eap_yaml_extension boolean NOT NULL,
    eap_bootable_jar boolean NOT NULL,
    eap_use_git boolean NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE public.eap_configuration(
    id uuid NOT NULL,
    eap_instance_id uuid NOT NULL;
  @ManyToMany
  @JoinTable(
      name = "eap_configuration_extensions",
      joinColumns = {@JoinColumn(name = "eap_configuration_id")},
      inverseJoinColumns = {@JoinColumn(name = "eap_extension_id")})
  public Set<EapExtension> extensions;

  // Each subsystem name maps to a json dump of its config
  @ElementCollection private Map<String, String> subsystems;

  // Each deployment name maps to a json dump of its config
  @ElementCollection private Map<String, String> deployments;
    version character varying(255) NOT NULL,
    launchType character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    organization character varying(255) NOT NULL,
    processType character varying(255) NOT NULL,
    productName character varying(255) NOT NULL,
    productVersion character varying(255) NOT NULL,
    profileName character varying(255) NOT NULL,
    releaseCodename character varying(255) NOT NULL,
    releaseVersion character varying(255) NOT NULL,
    runningMode character varying(255) NOT NULL,
    runtimeConfigurationState character varying(255) NOT NULL,
    serverState character varying(255) NOT NULL,
    suspendState character varying(255) NOT NULL,
    socketBindingGroups character varying NOT NULL,
    paths character varying NOT NULL,
    interfaces character varying NOT NULL,
    coreServices character varying NOT NULL,
    PRIMARY KEY (id)
);
CREATE TABLE public.eap_deployment(
    id uuid NOT NULL,
    eap_instance_id uuid NOT NULL;
    name character varying(255) NOT NULL,
  @ElementCollection private Set<JarHash> archives;
    PRIMARY KEY (id)
);
CREATE TABLE public.eap_extension(
    id uuid NOT NULL,
    eap_configuration uuid NOT NULL,
    module character varying(255) NOT NULL,

  @ElementCollection private Set<NameVersionPair> subsystems;
    PRIMARY KEY (id)
);

ALTER TABLE IF EXISTS eap_configuration
  ADD CONSTRAINT FK_EAP_CONFIGURATION_LINK_EAP_INSTANCE
    FOREIGN KEY (eap_instance_id) REFERENCES eap_instance(id)
ALTER TABLE IF EXISTS eap_deployment
  ADD CONSTRAINT FK_EAP_DEPLOYMENT_LINK_EAP_INSTANCE
    FOREIGN KEY (eap_instance_id) REFERENCES eap_instance(id)
ALTER TABLE IF EXISTS eap_extension
  ADD CONSTRAINT FK_EAP_EXTENSION_LINK_EAP_CONFIGURAITON
    FOREIGN KEY (eap_configuration) REFERENCES eap_configuration(id)
ALTER TABLE IF EXISTS eap_deployment
  ADD CONSTRAINT FK_EAP_EXTENSION_LINK_EAP_CONFIGURAITON
    FOREIGN KEY (eap_configuration) REFERENCES eap_configuration(id)
