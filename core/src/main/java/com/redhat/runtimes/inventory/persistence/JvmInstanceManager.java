/* Copyright (C) Red Hat 2023-2024 */
package com.redhat.runtimes.inventory.persistence;

import com.redhat.runtimes.inventory.models.JvmInstance;
import io.quarkus.logging.Log;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class JvmInstanceManager {
  @Inject EntityManager entityManager;

  @Transactional
  public void persist(JvmInstance inst) {
    if (inst == null) {
      return;
    }

    Log.debugf("About to persist: %s", inst);
    entityManager.persist(inst);
  }
}
