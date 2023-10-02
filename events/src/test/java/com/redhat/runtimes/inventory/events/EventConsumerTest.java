/* Copyright (C) Red Hat 2023 */
package com.redhat.runtimes.inventory.events;

import static com.redhat.runtimes.inventory.events.TestUtils.inputStreamFromResources;
import static com.redhat.runtimes.inventory.events.TestUtils.readBytesFromResources;
import static com.redhat.runtimes.inventory.events.TestUtils.readFromResources;
import static com.redhat.runtimes.inventory.events.Utils.instanceOf;
import static org.junit.jupiter.api.Assertions.*;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.redhat.runtimes.inventory.models.EapInstance;
import com.redhat.runtimes.inventory.models.JarHash;
import com.redhat.runtimes.inventory.models.JvmInstance;
import java.io.IOException;
import java.time.Instant;
import java.util.Map;
import java.util.Set;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

public class EventConsumerTest {

  @Test
  public void testEggUnzip() throws IOException {
    var archive = inputStreamFromResources("egg_upload.tar.gz");
    var jsonFiles = EventConsumer.getJsonsFromArchiveStream(archive);
  }

  @Test
  public void testSimpleUnzip() throws IOException {
    var buffy = readBytesFromResources("1J6DOEu9ni-000029.gz");
    var json = EventConsumer.unzipJson(buffy);
    TypeReference<Map<String, Object>> typeRef = new TypeReference<>() {};
    var mapper = new ObjectMapper();
    var o = mapper.readValue(json, typeRef);
    var idHash =
        "1fe34df6b75eaf557e59f58b88f584f398ed4b73e41730e3e88c34d6052ae231c677bdc1a1c5ce22202c485ce4f101f66fc283c5a7f81f51c59b09806b481f22";
    assertEquals(idHash, o.get("idHash"));
  }

  @Test
  public void test_jvmInstance_MWTELE_66() throws IOException {
    var dummy = new ArchiveAnnouncement();
    dummy.setTimestamp(Instant.now());

    var buffy = readBytesFromResources("jdk8_MWTELE-66.gz");
    var json = EventConsumer.unzipJson(buffy);

    var msg = instanceOf(dummy, json);
    assertTrue(msg instanceof JvmInstance);
    var inst = (JvmInstance) msg;

    var hostname = "fedora";
    assertEquals(hostname, inst.getHostname());

    json = readFromResources("test17.json");
    msg = instanceOf(dummy, json);
    assertTrue(msg instanceof JvmInstance);
    inst = (JvmInstance) msg;

    hostname = "uriel.local";
    assertEquals(hostname, inst.getHostname());
  }

  @Test
  @Disabled
  public void test_jvmInstance_MWTELE_67() throws IOException {
    var dummy = new ArchiveAnnouncement();
    dummy.setTimestamp(Instant.MIN);

    var buffy = readBytesFromResources("update1.json.gz");
    var json = EventConsumer.unzipJson(buffy);
    var msg = instanceOf(dummy, json);
    assertTrue(msg instanceof JvmInstance);
    var inst = (JvmInstance) msg;

    var hostname = "fedora";
    assertEquals(hostname, inst.getHostname());
  }

  @Test
  public void test_EapInstance_example1() throws IOException {
    var dummy = new ArchiveAnnouncement();
    dummy.setTimestamp(Instant.now());

    var json = readFromResources("eap_example1.json");
    var msg = instanceOf(dummy, json);
    assertTrue(msg instanceof EapInstance);
    var inst = (EapInstance) msg;

    var hostname = "freya";
    assertEquals(hostname, inst.getHostname());
    assertEquals(false, inst.getEapXp());
    assertEquals(
        "JBoss EAP 7.4.11.GA (WildFly Core 15.0.26.Final-redhat-00001)", inst.getEapVersion());
    assertEquals("7.4.11.GA", inst.getConfiguration().getProductVersion());
    // assertEquals(4708, inst.getModules().size());
    assertEquals(2, inst.getDeployments().size());

    assertEquals(2, inst.getConfiguration().getDeployments().size());
    assertEquals(39, inst.getConfiguration().getExtensions().size());
    assertNotNull(inst.getConfiguration().getCoreServices());
    assertNotNull(inst.getConfiguration().getInterfaces());
    assertNotNull(inst.getConfiguration().getPaths());
    assertNotNull(inst.getConfiguration().getSocketBindingGroups());
  }

  @Test
  @SuppressWarnings("unchecked")
  public void testJarHashAttributes() throws IOException {
    byte[] buffy = readBytesFromResources("jdk8_MWTELE-66.gz");
    String json = EventConsumer.unzipJson(buffy);
    ObjectMapper objectMapper = new ObjectMapper();
    Map<String, Object> map =
        objectMapper.readValue(json, new TypeReference<Map<String, Object>>() {});
    Set<JarHash> jarHashes = Utils.jarHashesOf((Map<String, Object>) map.get("jars"));
    assertEquals(1, jarHashes.size());
    JarHash jar = jarHashes.iterator().next();
    assertEquals("JBoss by Red Hat", jar.getVendor());
    assertEquals("82a8c99551533f4448675f273665cb6d7b750511", jar.getSha1Checksum());
    assertEquals(
        "d808a03cf5f844f0d1cf52b340a5c4ad836c052e1288a9b5ac8ca6df6ae9e000",
        jar.getSha256Checksum());
    assertEquals(
        "4c85d6f74cb8a34dca6748873f9b38457c04f253c4b7d1e088010d13eec7021145b338979adf8991f54c2b6241da7d350c2cfac849e603c286aa5fb13edf560f",
        jar.getSha512Checksum());
  }
}
